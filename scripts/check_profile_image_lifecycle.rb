#!/usr/bin/env ruby

def source_without_comments(path)
  source = File.read(path)
  source = source.gsub(%r{\/\*.*?\*\/}m, '')
  source.gsub(%r{//[^\n]*}, '')
end

def ordered?(source, first, second)
  first_index = source.index(first)
  second_index = source.index(second)
  first_index && second_index && first_index < second_index
end

failures = []
home = source_without_comments('app/src/main/java/com/example/app/HomeActivity.java')
publication = source_without_comments(
  'app/src/main/java/com/example/app/ProfileImagePublication.java'
)

[
  'long begin()',
  'void invalidate()',
  'boolean canPublish(long revision)',
  'return revision == currentRevision;'
].each do |contract|
  failures << "profile publication must include #{contract}" unless publication.include?(contract)
end

[
  'new ProfileImagePublication()',
  'private GetXMLTask profileImageTask;',
  'profileImageTask = new GetXMLTask();',
  'profileImageTask.execute(new String[] { twitter_pic});',
  'profileImagePublication.invalidate();',
  'profileImageTask.cancel(true);',
  'private final long revision = profileImagePublication.begin();',
  'isCancelled() || !profileImagePublication.canPublish(revision)',
  'httpConnection.setConnectTimeout(30000);',
  'httpConnection.setReadTimeout(30000);',
  'httpConnection.disconnect();'
].each do |contract|
  failures << "Home profile image lifecycle must include #{contract}" unless home.include?(contract)
end

logout = home.match(/private\s+void\s+logoutFromTwitter\s*\(\s*\)\s*\{(?<body>.*?)^    \}/m)
unless logout && ordered?(
  logout[:body], 'invalidateProfileImageTask();', 'startActivity(goToNextActivity);'
)
  failures << 'logout must invalidate profile image work before navigation'
end

destroy = home.match(/protected\s+void\s+onDestroy\s*\(\s*\)\s*\{(?<body>.*?)^    \}/m)
unless destroy && ordered?(
  destroy[:body], 'invalidateProfileImageTask();', 'super.onDestroy();'
)
  failures << 'teardown must invalidate profile image work before super'
end

download = home.match(/private\s+Bitmap\s+downloadImage\s*\([^)]*\)\s*\{(?<body>.*?)\n        \}/m)
unless download && ordered?(
  download[:body], 'stream.close();', 'httpConnection.disconnect();'
)
  failures << 'profile image download must close its stream before disconnect'
end
unless download && ordered?(
  download[:body], 'httpConnection = getHttpConnection(url);', 'httpConnection.connect();'
) && ordered?(
  download[:body], 'httpConnection.connect();', 'httpConnection.getResponseCode()'
)
  failures << 'profile image download must own the connection before connect and response work'
end

if failures.empty?
  puts 'Profile image lifecycle source checks passed'
else
  warn "Profile image lifecycle source checks failed:\n- #{failures.join("\n- ")}"
  exit 1
end
