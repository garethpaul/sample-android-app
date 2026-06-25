#!/usr/bin/env ruby

def source_without_comments(path)
  source = File.read(path)
  source = source.gsub(%r{/\*.*?\*/}m, '')
  source.gsub(%r{//[^\n]*}, '')
end

failures = []
home_path = 'app/src/main/java/com/example/app/HomeActivity.java'
publication_path = 'app/src/main/java/com/example/app/TimelinePublication.java'

unless File.exist?(home_path)
  failures << "#{home_path} is missing"
end
unless File.exist?(publication_path)
  failures << "#{publication_path} is missing"
end

if failures.empty?
  home = source_without_comments(home_path)
  publication = source_without_comments(publication_path)

  failures << 'timeline rows must not be appended directly to the displayed holder' if
    home.match?(/tweet_holder\s*\.\s*add\s*\(/)
  failures << 'each GetTweets task must capture its revision before execution' unless
    home.match?(/private\s+final\s+long\s+revision\s*=\s*timelinePublication\s*\.\s*begin\s*\(\s*\)\s*;/)
  failures << 'each GetTweets task must own a fresh local result list' unless
    home.match?(/private\s+final\s+ArrayList<Tweet>\s+fetchedTweets\s*=\s*new\s+ArrayList<Tweet>\s*\(\s*\)\s*;/)
  failures << 'GetTweets must return the fetch success result' unless
    home.match?(/protected\s+Boolean\s+doInBackground\s*\([^)]*\)\s*\{.*?return\s+bringTweets\s*\(\s*\)\s*;/m)
  failures << 'Twitter failures must return false without publishing partial rows' unless
    home.match?(/catch\s*\(\s*TwitterException\s+\w+\s*\)\s*\{.*?return\s+false\s*;/m)
  failures << 'fetched statuses must remain task-local' unless
    home.match?(/List<Status>\s+statuses\s*=\s*twitter\s*\.\s*getHomeTimeline\s*\(\s*paging\s*\)\s*;/)
  failures << 'timeline conversion must append only to task-local rows' unless
    home.match?(/fetchedTweets\s*\.\s*add\s*\(\s*new\s+Tweet\s*\(/)
  completion = home.match(/boolean\s+successful\s*=\s*Boolean\.TRUE\.equals\s*\(\s*r\s*\)\s*;\s*if\s*\(\s*!timelinePublication\s*\.\s*publish\s*\(\s*revision\s*,\s*successful\s*,\s*fetchedTweets\s*\)\s*\)\s*\{\s*return\s*;\s*\}(.*?)if\s*\(\s*successful\s*\)\s*\{(.*?)lv\s*\.\s*setAdapter\s*\(\s*adapter\s*\)\s*;/m)
  failures << 'loading and adapter changes must follow the same current-revision decision' unless completion
  if completion
    loading_updates = completion[1]
    failures << 'current completion must hide the progress view' unless
      loading_updates.match?(/progress\s*\.\s*setVisibility\s*\(\s*View\.INVISIBLE\s*\)\s*;/)
    failures << 'current completion must hide the loading label' unless
      loading_updates.match?(/loading\s*\.\s*setVisibility\s*\(\s*View\.INVISIBLE\s*\)\s*;/)
  end

  failures << 'timeline publication must reject stale revisions' unless
    publication.match?(/if\s*\(\s*revision\s*!=\s*currentRevision\s*\)\s*\{\s*return\s+false\s*;/m)
  failures << 'timeline publication must support lifecycle invalidation' unless
    publication.match?(/void\s+invalidate\s*\(\s*\)\s*\{\s*currentRevision\s*\+=\s*1\s*;\s*\}/m)
  replacement = publication.match(/if\s*\(\s*successful\s*\)\s*\{\s*displayedRows\s*\.\s*clear\s*\(\s*\)\s*;\s*displayedRows\s*\.\s*addAll\s*\(\s*fetchedRows\s*\)\s*;\s*\}\s*return\s+true\s*;/m)
  failures << 'current completion must be accepted while only success replaces displayed rows' unless replacement

  logout = home.match(/private\s+void\s+logoutFromTwitter\s*\(\s*\)\s*\{(?<body>.*?)^    \}/m)
  if logout
    invalidate = logout[:body].index('timelinePublication.invalidate();')
    navigation = logout[:body].index('startActivity(goToNextActivity);')
    failures << 'successful logout must invalidate pending timeline publication before navigation' unless
      invalidate && navigation && invalidate < navigation
  else
    failures << 'HomeActivity must keep logout lifecycle handling'
  end

  destroy = home.match(/protected\s+void\s+onDestroy\s*\(\s*\)\s*\{(?<body>.*?)^    \}/m)
  if destroy
    destroy_body = destroy[:body]
    invalidate = destroy_body.index('timelinePublication.invalidate();')
    null_guard = destroy_body.index('if (moPubView != null)')
    ad_destroy = destroy_body.index('moPubView.destroy();')
    super_destroy = destroy_body.index('super.onDestroy();')
    failures << 'Home teardown must invalidate timeline publication and destroy the initialized ad view' unless
      invalidate && null_guard && ad_destroy && super_destroy &&
      invalidate < null_guard && null_guard < ad_destroy && ad_destroy < super_destroy
  else
    failures << 'HomeActivity must keep lifecycle teardown'
  end
end

if failures.empty?
  puts 'Timeline refresh source checks passed'
else
  warn "Timeline refresh source checks failed:\n- #{failures.join("\n- ")}"
  exit 1
end
