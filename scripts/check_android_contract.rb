#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rexml/document'

failures = []

docs_plans = Dir['docs/plans/*.md'].sort
canonical_plan = 'docs/plans/2026-06-08-sample-android-app-baseline.md'
failures << "#{canonical_plan} is missing" unless File.exist?(canonical_plan)
failures << 'docs/plans must contain at least one completed plan' if docs_plans.empty?

docs_plans.each do |plan_path|
  plan = File.read(plan_path)
  unless plan.include?('Status: Completed') && plan.include?('make check')
    failures << "#{plan_path} must record completed status and make check verification"
  end
end

unless File.executable?('gradlew')
  failures << 'gradlew must be executable'
end

wrapper_properties = File.read('gradle/wrapper/gradle-wrapper.properties')
if wrapper_properties.include?('distributionUrl=http\\://')
  failures << 'gradle wrapper distributionUrl must use https'
end

root_build = File.read('build.gradle')
if root_build.include?('mavenCentral()')
  failures << 'legacy Gradle 1.10 build must use explicit HTTPS Maven Central URLs'
end
if root_build.include?('com.android.tools.build:gradle:0.8.+')
  failures << 'Android Gradle plugin version must be pinned for reproducibility'
end

app_build = File.read('app/build.gradle')
if app_build.include?('appcompat-v7:+')
  failures << 'Android support library version must be pinned for reproducibility'
end

tracked_build_outputs = `git ls-files build app/build`.split("\n")
unless tracked_build_outputs.empty?
  failures << "generated build outputs must not be tracked: #{tracked_build_outputs.join(', ')}"
end

gitignore = File.exist?('.gitignore') ? File.read('.gitignore') : ''
%w[build/ app/build/ Const.java *.class *.dex].each do |pattern|
  failures << ".gitignore must include #{pattern}" unless gitignore.lines.map(&:strip).include?(pattern)
end

tracked_const = `git ls-files app/src/main/java/com/example/app/Const.java`.strip
failures << 'real Const.java must stay untracked' unless tracked_const.empty?

manifest_path = 'app/src/main/AndroidManifest.xml'
if File.exist?(manifest_path)
  manifest = File.read(manifest_path)
  unless manifest.include?('android:allowBackup="false"')
    failures << "#{manifest_path} must disable android:allowBackup"
  end

  begin
    manifest_doc = REXML::Document.new(manifest)
    launcher_activities = []
    oauth_activities = []

    REXML::XPath.each(manifest_doc, '/manifest/application/activity') do |activity|
      activity_name = activity.attributes['android:name']
      activity.get_elements('intent-filter').each do |intent_filter|
        actions = intent_filter.get_elements('action').map { |action| action.attributes['android:name'] }
        categories = intent_filter.get_elements('category').map { |category| category.attributes['android:name'] }
        oauth_data = intent_filter.get_elements('data').any? do |data|
          data.attributes['android:scheme'] == 'oauth' && data.attributes['android:host'] == 't4jsample'
        end

        if actions.include?('android.intent.action.MAIN') &&
           categories.include?('android.intent.category.LAUNCHER')
          launcher_activities << activity_name
        end

        if actions.include?('android.intent.action.VIEW') &&
           categories.include?('android.intent.category.BROWSABLE') &&
           oauth_data
          oauth_activities << activity_name
        end
      end
    end

    expected_entrypoint = ['com.example.app.MainActivity']
    unless launcher_activities == expected_entrypoint
      failures << "#{manifest_path} must expose only MainActivity as the launcher entry point"
    end
    unless oauth_activities == expected_entrypoint
      failures << "#{manifest_path} must expose only MainActivity for the oauth://t4jsample callback"
    end
  rescue REXML::ParseException => e
    failures << "#{manifest_path} is invalid XML: #{e.message}"
  end
else
  failures << "#{manifest_path} is missing"
end

const_example = 'app/src/main/java/com/example/app/Const.java.example'
if File.exist?(const_example)
  source = File.read(const_example)
  failures << "#{const_example} must define public class Const" unless source.include?('public class Const')
  %w[TWITTER_CONSUMER_KEY TWITTER_CONSUMER_SECRET MoPubBannerId MoPubMiniBannerId].each do |field|
    value = source[/#{field}\s*=\s*"([^"]+)"/, 1]
    if value.nil?
      failures << "#{const_example} must define #{field}"
    elsif !value.start_with?('replace-with-')
      failures << "#{const_example} must keep #{field} as a placeholder"
    end
  end
else
  failures << "#{const_example} is missing"
end

Dir['app/src/main/java/**/*.java'].each do |path|
  next if path.end_with?('Const.java.example')

  source = File.read(path)
  if source.match?(/setAdUnitId\("([^"]+)"/)
    failures << "#{path} hardcodes an ad unit in setAdUnitId"
  end
end

utils_path = 'app/src/main/java/com/example/app/Utils.java'
if File.exist?(utils_path)
  utils_source = File.read(utils_path)
  if utils_source.match?(/catch\s*\(\s*Exception\b/)
    failures << "#{utils_path} must not swallow broad Exception failures"
  end
  unless utils_source.match?(/catch\s*\(\s*IOException\b/)
    failures << "#{utils_path} must catch IOException for stream-copy failures"
  end
  unless utils_source.include?('Log.e(TAG, "Failed to copy stream", ex);')
    failures << "#{utils_path} must log stream-copy IOException failures"
  end
else
  failures << "#{utils_path} is missing"
end

if failures.empty?
  puts 'Android sample contract checks passed'
else
  warn "Android sample contract checks failed:\n- #{failures.join("\n- ")}"
  exit 1
end
