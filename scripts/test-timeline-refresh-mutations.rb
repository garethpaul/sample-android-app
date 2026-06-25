#!/usr/bin/env ruby

require 'fileutils'
require 'open3'
require 'tmpdir'

root = File.expand_path('..', __dir__)
home_path = 'app/src/main/java/com/example/app/HomeActivity.java'
publication_path = 'app/src/main/java/com/example/app/TimelinePublication.java'
checker_path = 'scripts/check_timeline_refresh.rb'

mutations = {
  'direct displayed append' => [home_path, 'fetchedTweets.add(new Tweet(', 'tweet_holder.add(new Tweet('],
  'shared task rows' => [home_path, 'private final ArrayList<Tweet> fetchedTweets', 'private static final ArrayList<Tweet> fetchedTweets'],
  'ignored fetch result' => [home_path, 'return bringTweets();', 'bringTweets(); return true;'],
  'failure reported as success' => [home_path, 'return false;', 'return true;'],
  'unconditional adapter replacement' => [home_path,
    'if (successful) {',
    'if (true) {'],
  'unconditional loading hide' => [home_path,
    'if (!timelinePublication.publish(revision, successful, fetchedTweets)) {',
    'timelinePublication.publish(revision, successful, fetchedTweets); if (false) {'],
  'stale loading hide' => [home_path,
    "boolean successful = Boolean.TRUE.equals(r);\n            if (!timelinePublication.publish",
    "boolean successful = Boolean.TRUE.equals(r);\n            loading = (TextView) findViewById(R.id.loading);\n            loading.setVisibility(View.INVISIBLE);\n            if (!timelinePublication.publish"],
  'stale completion enabled' => [publication_path,
    'if (revision != currentRevision)',
    'if (false)'],
  'failed completion replaces rows' => [publication_path,
    'if (successful)',
    'if (true)'],
  'append instead of replace' => [publication_path,
    'displayedRows.clear();',
    'displayedRows.size();']
}

mutations.each do |name, (path, before, after)|
  Dir.mktmpdir('sample-android-app-timeline-mutation') do |directory|
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
      warn "timeline refresh checker accepted hostile mutation: #{name}"
      exit 1
    end
  end
end

puts "Timeline refresh mutation tests passed (#{mutations.length} mutations)"
