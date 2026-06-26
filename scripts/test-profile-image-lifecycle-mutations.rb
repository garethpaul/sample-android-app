#!/usr/bin/env ruby

require 'fileutils'
require 'open3'
require 'tmpdir'

root = File.expand_path('..', __dir__)
home_path = 'app/src/main/java/com/example/app/HomeActivity.java'
publication_path = 'app/src/main/java/com/example/app/ProfileImagePublication.java'
checker_path = 'scripts/check_profile_image_lifecycle.rb'

mutations = {
  'stale publication enabled' => [publication_path,
    'return revision == currentRevision;', 'return true;'],
  'logout invalidation removed' => [home_path,
    "timelinePublication.invalidate();\n        invalidateProfileImageTask();",
    "timelinePublication.invalidate();\n        profileImagePublication.begin();"],
  'teardown invalidation removed' => [home_path,
    "protected void onDestroy() {\n        timelinePublication.invalidate();\n        invalidateProfileImageTask();",
    "protected void onDestroy() {\n        timelinePublication.invalidate();\n        profileImagePublication.begin();"],
  'task cancellation removed' => [home_path,
    'profileImageTask.cancel(true);', 'profileImageTask.isCancelled();'],
  'completion guard removed' => [home_path,
    'if (isCancelled() || !profileImagePublication.canPublish(revision)) {',
    'if (false) {'],
  'connect timeout removed' => [home_path,
    'httpConnection.setConnectTimeout(30000);',
    'httpConnection.getConnectTimeout();'],
  'read timeout removed' => [home_path,
    'httpConnection.setReadTimeout(30000);',
    'httpConnection.getReadTimeout();'],
  'disconnect removed' => [home_path,
    'httpConnection.disconnect();', 'httpConnection.getResponseCode();'],
  'connection ownership delayed' => [home_path,
    "httpConnection = getHttpConnection(url);\n                if(httpConnection == null)\n                    return null;\n                httpConnection.connect();\n                if (httpConnection.getResponseCode() != HttpURLConnection.HTTP_OK)\n                    return null;\n                stream = httpConnection.getInputStream();",
    "httpConnection = null;\n                stream = getHttpConnection(url).getInputStream();"]
}

mutations.each do |name, (path, before, after)|
  Dir.mktmpdir('sample-android-app-profile-image-mutation') do |directory|
    [home_path, publication_path, checker_path].each do |relative|
      destination = File.join(directory, relative)
      FileUtils.mkdir_p(File.dirname(destination))
      FileUtils.cp(File.join(root, relative), destination)
    end

    target = File.join(directory, path)
    source = File.read(target)
    unless source.include?(before)
      warn "mutation fixture missing for #{name}"
      exit 1
    end
    File.write(target, source.sub(before, after))

    _output, status = Open3.capture2e('ruby', checker_path, chdir: directory)
    if status.success?
      warn "profile image lifecycle checker accepted hostile mutation: #{name}"
      exit 1
    end
  end
end

puts "Profile image lifecycle mutation tests passed (#{mutations.length} mutations)"
