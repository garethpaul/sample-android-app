#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rexml/document'

failures = []

docs_plans = Dir['docs/plans/*.md'].sort
canonical_plan = 'docs/plans/2026-06-08-sample-android-app-baseline.md'
ide_metadata_plan = 'docs/plans/2026-06-09-ide-metadata-ignore.md'
exported_state_plan = 'docs/plans/2026-06-09-manifest-exported-state.md'
failures << "#{canonical_plan} is missing" unless File.exist?(canonical_plan)
failures << "#{ide_metadata_plan} is missing" unless File.exist?(ide_metadata_plan)
failures << "#{exported_state_plan} is missing" unless File.exist?(exported_state_plan)
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
%w[build/ app/build/ Const.java *.class *.dex .idea/ *.iml].each do |pattern|
  failures << ".gitignore must include #{pattern}" unless gitignore.lines.map(&:strip).include?(pattern)
end

tracked_ide_metadata = `git ls-files .idea '*.iml'`.split("\n").select { |path| File.exist?(path) }
unless tracked_ide_metadata.empty?
  failures << "IDE metadata must not be tracked: #{tracked_ide_metadata.join(', ')}"
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
    declared_permissions = REXML::XPath.match(manifest_doc, '/manifest/uses-permission').map do |permission|
      permission.attributes['android:name']
    end.compact.sort
    expected_permissions = [
      'android.permission.ACCESS_NETWORK_STATE',
      'android.permission.INTERNET'
    ].sort
    unless declared_permissions == expected_permissions
      failures << "#{manifest_path} must request only #{expected_permissions.join(', ')}"
    end

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

    expected_exported = {
      'com.example.app.MainActivity' => 'true',
      'com.example.app.HomeActivity' => 'false'
    }
    expected_exported.each do |activity_name, exported|
      activity = REXML::XPath.first(
        manifest_doc,
        "/manifest/application/activity[@android:name='#{activity_name}']"
      )
      if activity.nil?
        failures << "#{manifest_path} must declare #{activity_name}"
      elsif activity.attributes['android:exported'] != exported
        failures << "#{manifest_path} must set #{activity_name} android:exported=\"#{exported}\""
      end
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
  unless utils_source.include?('public static boolean CopyStream')
    failures << "#{utils_path} must return whether stream-copy completed"
  end
  unless utils_source.include?('return true;') && utils_source.include?('return false;')
    failures << "#{utils_path} must return true on successful stream copy and false on IOException"
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

file_cache_path = 'app/src/main/java/com/example/app/FileCache.java'
if File.exist?(file_cache_path)
  file_cache_source = File.read(file_cache_path)
  if file_cache_source.include?('getExternalStorageDirectory') ||
     file_cache_source.include?('Environment.getExternalStorageState')
    failures << "#{file_cache_path} must keep image cache data in app-internal cache storage"
  end
  unless file_cache_source.include?('context.getCacheDir()')
    failures << "#{file_cache_path} must use context.getCacheDir() for image cache storage"
  end
else
  failures << "#{file_cache_path} is missing"
end

image_loader_path = 'app/src/main/java/com/example/app/ImageLoader.java'
if File.exist?(image_loader_path)
  image_loader_source = File.read(image_loader_path)
  if image_loader_source.include?('printStackTrace()')
    failures << "#{image_loader_path} must log image load failures instead of printing stack traces"
  end
  if image_loader_source.match?(/catch\s*\(\s*Exception\b/)
    failures << "#{image_loader_path} must not catch broad Exception while loading images"
  end
  if image_loader_source.match?(/^\s*Utils\.CopyStream\(is, os\);/)
    failures << "#{image_loader_path} must branch on stream-copy success before decoding cached images"
  end
  unless image_loader_source.include?('copied = Utils.CopyStream(is, os);') &&
         image_loader_source.include?('if(!copied)')
    failures << "#{image_loader_path} must stop decoding when an image cache write fails"
  end
  unless image_loader_source.include?('deleteQuietly(f);') &&
         image_loader_source.include?('Failed to delete partial image cache file')
    failures << "#{image_loader_path} must delete partial image cache files after failed writes"
  end
  unless image_loader_source.include?('Log.e(TAG, "Failed to load image", ex);')
    failures << "#{image_loader_path} must log image load IOException failures"
  end
  unless image_loader_source.include?('if(bitmap == null)')
    failures << "#{image_loader_path} must guard failed bitmap decodes before rounding images"
  end
  if image_loader_source.match?(/catch\s*\(\s*FileNotFoundException\s+\w+\)\s*\{\s*\}/)
    failures << "#{image_loader_path} must log cached image decode FileNotFoundException failures"
  end
  unless image_loader_source.include?('InputStream boundsStream = null;') &&
         image_loader_source.include?('InputStream bitmapStream = null;') &&
         image_loader_source.include?('closeQuietly(boundsStream);') &&
         image_loader_source.include?('closeQuietly(bitmapStream);')
    failures << "#{image_loader_path} must close cached image decode streams"
  end
  unless image_loader_source.include?('Log.e(TAG, "Failed to decode cached image", ex);')
    failures << "#{image_loader_path} must log cached image decode failures"
  end
  unless image_loader_source.include?('if(url == null || url.length() == 0)') &&
         image_loader_source.include?('imageViews.remove(imageView);') &&
         image_loader_source.include?('imageView.setImageResource(stub_id);')
    failures << "#{image_loader_path} must show the placeholder and skip loading when an image URL is empty"
  end
else
  failures << "#{image_loader_path} is missing"
end

home_activity_path = 'app/src/main/java/com/example/app/HomeActivity.java'
if File.exist?(home_activity_path)
  home_activity_source = File.read(home_activity_path)
  if home_activity_source.include?('printStackTrace()')
    failures << "#{home_activity_path} must log failures instead of printing stack traces"
  end
  if home_activity_source.match?(/catch\s*\(\s*Exception\b/)
    failures << "#{home_activity_path} must not catch broad Exception while loading profile images"
  end
  unless home_activity_source.include?('Log.e(TAG, "Failed to download profile image", ex);')
    failures << "#{home_activity_path} must log profile image download IOException failures"
  end
  unless home_activity_source.include?('if(bitmap == null)')
    failures << "#{home_activity_path} must guard failed profile bitmap decodes before rounding images"
  end
  unless home_activity_source.include?('imageView.setImageResource(R.drawable.no_image);')
    failures << "#{home_activity_path} must show the placeholder image when profile image loading fails"
  end
else
  failures << "#{home_activity_path} is missing"
end

if failures.empty?
  puts 'Android sample contract checks passed'
else
  warn "Android sample contract checks failed:\n- #{failures.join("\n- ")}"
  exit 1
end
