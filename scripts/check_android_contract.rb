#!/usr/bin/env ruby
# frozen_string_literal: true

failures = []

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

if failures.empty?
  puts 'Android sample contract checks passed'
else
  warn "Android sample contract checks failed:\n- #{failures.join("\n- ")}"
  exit 1
end
