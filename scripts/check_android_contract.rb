#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rexml/document'
require 'digest'
require 'yaml'

ROOT = File.expand_path('..', __dir__)
Dir.chdir(ROOT)

failures = []

docs_plans = Dir['docs/plans/*.md'].sort
canonical_plan = 'docs/plans/2026-06-08-sample-android-app-baseline.md'
ide_metadata_plan = 'docs/plans/2026-06-09-ide-metadata-ignore.md'
exported_state_plan = 'docs/plans/2026-06-09-manifest-exported-state.md'
ci_plan = 'docs/plans/2026-06-10-ci-baseline.md'
vendored_integrity_plan = 'docs/plans/2026-06-10-vendored-sdk-integrity.md'
sensitive_log_plan = 'docs/plans/2026-06-12-sensitive-log-redaction.md'
logout_credential_plan = 'docs/plans/2026-06-13-logout-credential-purge.md'
oauth_callback_plan = 'docs/plans/2026-06-13-oauth-callback-correlation.md'
make_root_plan = 'docs/plans/2026-06-14-make-root-override-protection.md'
make_authority_plan = 'docs/plans/2026-06-21-make-authority-isolation.md'
oauth_callback_address_plan = 'docs/plans/2026-06-14-oauth-callback-address-integrity.md'
oauth_request_token_consumption_plan = 'docs/plans/2026-06-14-oauth-request-token-consumption.md'
oauth_request_token_retry_reset_plan = 'docs/plans/2026-06-15-oauth-request-token-retry-reset.md'
oauth_session_persistence_plan = 'docs/plans/2026-06-16-oauth-session-persistence.md'
oauth_session_integrity_plan = 'docs/plans/2026-06-16-oauth-session-integrity.md'
logout_back_stack_plan = 'docs/plans/2026-06-17-logout-back-stack-revocation.md'
home_lifecycle_plan = 'docs/plans/2026-06-25-home-timeline-lifecycle.md'
profile_image_design = 'docs/plans/2026-06-25-profile-image-lifecycle-design.md'
profile_image_plan = 'docs/plans/2026-06-25-profile-image-lifecycle.md'
ci_workflow = '.github/workflows/check.yml'
workflow_dir = '.github/workflows'
codeowners = '.github/CODEOWNERS'
failures << "#{canonical_plan} is missing" unless File.exist?(canonical_plan)
failures << "#{ide_metadata_plan} is missing" unless File.exist?(ide_metadata_plan)
failures << "#{exported_state_plan} is missing" unless File.exist?(exported_state_plan)
failures << "#{ci_plan} is missing" unless File.exist?(ci_plan)
failures << "#{vendored_integrity_plan} is missing" unless File.exist?(vendored_integrity_plan)
failures << "#{sensitive_log_plan} is missing" unless File.exist?(sensitive_log_plan)
failures << "#{logout_credential_plan} is missing" unless File.exist?(logout_credential_plan)
failures << "#{oauth_callback_plan} is missing" unless File.exist?(oauth_callback_plan)
failures << "#{make_root_plan} is missing" unless File.exist?(make_root_plan)
failures << "#{make_authority_plan} is missing" unless File.exist?(make_authority_plan)
failures << "#{oauth_callback_address_plan} is missing" unless File.exist?(oauth_callback_address_plan)
failures << "#{oauth_request_token_consumption_plan} is missing" unless File.exist?(oauth_request_token_consumption_plan)
failures << "#{oauth_request_token_retry_reset_plan} is missing" unless File.exist?(oauth_request_token_retry_reset_plan)
failures << "#{oauth_session_persistence_plan} is missing" unless File.exist?(oauth_session_persistence_plan)
failures << "#{oauth_session_integrity_plan} is missing" unless File.exist?(oauth_session_integrity_plan)
failures << "#{logout_back_stack_plan} is missing" unless File.exist?(logout_back_stack_plan)
failures << "#{home_lifecycle_plan} is missing" unless File.exist?(home_lifecycle_plan)
failures << "#{profile_image_design} is missing" unless File.exist?(profile_image_design)
failures << "#{profile_image_plan} is missing" unless File.exist?(profile_image_plan)
failures << 'ProfileImagePublication.java is missing' unless File.exist?(
  'app/src/main/java/com/example/app/ProfileImagePublication.java'
)
failures << 'profile image publication test is missing' unless File.exist?(
  'scripts/test-profile-image-publication.sh'
)
failures << 'profile image lifecycle checker is missing' unless File.exist?(
  'scripts/check_profile_image_lifecycle.rb'
)
failures << 'profile image lifecycle mutation suite is missing' unless File.exist?(
  'scripts/test-profile-image-lifecycle-mutations.rb'
)
failures << "#{ci_workflow} is missing" unless File.exist?(ci_workflow)
failures << "#{codeowners} is missing" unless File.exist?(codeowners)
failures << 'docs/plans must contain at least one completed plan' if docs_plans.empty?

docs_plans.each do |plan_path|
  plan = File.read(plan_path)
  unless plan.include?('Status: Completed') && plan.include?('make check')
    failures << "#{plan_path} must record completed status and make check verification"
  end
end

makefile = File.read('Makefile')
root_declaration = %q(override ROOT := $(shell sed_path=/usr/bin/sed; [ -x "$$sed_path" ] || sed_path=/bin/sed; [ -x "$$sed_path" ] || exit 1; path=$$(printf '%s' '$(subst ','"'"',$(MAKEFILE_LIST))' | "$$sed_path" 's/^ //'); [ -f "$$path" ] || exit 1; directory=$${path%/*}; [ "$$directory" != "$$path" ] || directory=.; CDPATH= cd "$$directory" && pwd -P))
root_assignments = makefile.lines.map(&:chomp).grep(/\A(?:override\s+)?ROOT\s*[:?+]?=/)
required_make_authority = [
  'override SHELL := /bin/sh',
  'override .SHELLFLAGS := -c',
  '.SECONDEXPANSION:',
  'override RUBY := ruby',
  '$(error MAKEFILES must be empty; repository verification requires this Makefile to be loaded alone)',
  'override MAKEFILES :=',
  '$(error MAKEFILE_LIST must not be overridden)',
  root_declaration,
  'export ROOT',
  'export RUN_LEGACY_GRADLE',
  'export ANDROID_HOME',
  '$(error repository Makefile path could not be resolved)',
  'root-test:',
  "\t/bin/sh \"$$ROOT/scripts/test-makefile-root.sh\"",
  'verify: root-test lint test build'
]
unless root_assignments == [root_declaration] &&
       required_make_authority.all? { |line| makefile.lines.map(&:chomp).include?(line) } &&
       makefile.include?('build check lint root-test test verify: $$(if $$(shell') &&
       makefile.include?('$$(error repository Makefile must be loaded alone))')
  failures << 'Makefile must preserve the isolated repository-owned verification authority contract'
end
[
  'cd "$$ROOT" && $(RUBY) scripts/check_profile_image_lifecycle.rb',
  '/bin/sh "$$ROOT/scripts/test-profile-image-publication.sh"',
  'cd "$$ROOT" && $(RUBY) scripts/test-profile-image-lifecycle-mutations.rb'
].each do |command|
  failures << "Makefile must execute #{command}" unless makefile.include?(command)
end

root_test = 'scripts/test-makefile-root.sh'
if File.exist?(root_test)
  root_test_text = File.read(root_test)
  ['54 executed target/authority cases', '2 inert configuration-data cases', 'MAKEFILE_LIST must not be overridden', 'MAKEFILES must be empty', 'repository Makefile path could not be resolved', 'repository Makefile must be loaded alone', 'detected MAKEFILES preload startup', '2 multi-Makefile rejections', '1 dollar-path non-execution case'].each do |evidence|
    failures << "#{root_test} must preserve #{evidence.inspect}" unless root_test_text.include?(evidence)
  end
else
  failures << "#{root_test} is missing"
end

if File.exist?(make_authority_plan)
  authority_plan = File.read(make_authority_plan)
  ['Status: Completed', '`make root-test` passed 54 target/authority cases', '`make check` passed from the repository and through an absolute Makefile path'].each do |evidence|
    failures << "#{make_authority_plan} must record verification evidence #{evidence.inspect}" unless authority_plan.include?(evidence)
  end
end

if File.exist?(make_root_plan)
  root_plan = File.read(make_root_plan)
  [
    'Status: Completed',
    '`make ROOT=/tmp check` passed',
    'all five public Make aliases passed',
    'Six hostile mutations were rejected',
    'Ruby 3.3'
  ].each do |evidence|
    failures << "#{make_root_plan} must record verification evidence #{evidence.inspect}" unless root_plan.include?(evidence)
  end
end

if File.exist?(ci_workflow)
  workflow = File.read(ci_workflow)
  unless workflow.include?('actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10') &&
         workflow.include?('ruby/setup-ruby@12fd324f1d0b43274fdc8130f6980590a667c455') &&
         workflow.include?('ruby-version: "3.3"') &&
         workflow.include?('runs-on: ubuntu-24.04') &&
         workflow.include?('concurrency:') &&
         workflow.include?('cancel-in-progress: true') &&
         workflow.include?('permissions:') &&
         workflow.include?('contents: read') &&
         workflow.include?('persist-credentials: false') &&
         workflow.include?('timeout-minutes: 5') &&
         workflow.include?("  pull_request:\n") &&
         workflow.include?("  push:\n") &&
         workflow.include?('workflow_dispatch:') &&
         workflow.include?('run: make check')
    failures << "#{ci_workflow} must keep the pinned, least-privilege Ruby 3.3 check baseline"
  end
  if workflow.match?(/^\s+(?:branches|branches-ignore|paths|paths-ignore|tags|tags-ignore):/)
    failures << "#{ci_workflow} must validate every pushed branch and pull request"
  end
  failures << "#{ci_workflow} must not conditionally skip verification" if workflow.match?(/^\s+if:/)
  failures << "#{ci_workflow} must not allow verification failures" if workflow.include?('continue-on-error')
  failures << "#{ci_workflow} must not grant write permissions" if workflow.match?(/^\s*[\w-]+:\s*write\s*$/)
  failures << "#{ci_workflow} must include one checkout action" unless workflow.scan(/actions\/checkout@/).length == 1
  failures << "#{ci_workflow} must include one Ruby setup action" unless workflow.scan(/ruby\/setup-ruby@/).length == 1
  unless workflow.scan('persist-credentials: false').length == 1
    failures << "#{ci_workflow} must disable checkout credential persistence exactly once"
  end
  workflow.scan(/^\s*uses:\s*([^@\s]+)@([^\s#]+)/).each do |action, revision|
    unless revision.match?(/\A[a-f0-9]{40}\z/)
      failures << "#{ci_workflow} action #{action} must be pinned to a full commit SHA"
    end
  end

  begin
    workflow_config = YAML.safe_load(
      workflow,
      permitted_classes: [],
      permitted_symbols: [],
      aliases: true
    )
    workflow_events = workflow_config['on'] || workflow_config[true]
    check_job = workflow_config.dig('jobs', 'check')
    steps = check_job.is_a?(Hash) && check_job['steps'].is_a?(Array) ? check_job['steps'] : []
    checkout_steps = steps.select { |step| step['uses'].to_s.start_with?('actions/checkout@') }
    ruby_steps = steps.select { |step| step['uses'].to_s.start_with?('ruby/setup-ruby@') }
    run_steps = steps.select { |step| step['run'] == 'make check' }

    unless workflow_events.is_a?(Hash) &&
           workflow_events.key?('pull_request') &&
           workflow_events.key?('push') &&
           workflow_events.key?('workflow_dispatch') &&
           workflow_events['pull_request'].nil? &&
           workflow_events['push'].nil?
      failures << "#{ci_workflow} must structurally enable unfiltered push, pull request, and manual checks"
    end
    unless workflow_config['permissions'] == { 'contents' => 'read' }
      failures << "#{ci_workflow} must structurally keep top-level contents read-only permissions"
    end
    unless check_job.is_a?(Hash) &&
           check_job['runs-on'] == 'ubuntu-24.04' &&
           check_job['timeout-minutes'] == 5 &&
           !check_job.key?('if') &&
           !check_job.key?('continue-on-error') &&
           !check_job.key?('permissions')
      failures << "#{ci_workflow} must structurally keep the bounded, unconditional check job"
    end
    unless checkout_steps.length == 1 &&
           checkout_steps.first['uses'] == 'actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10' &&
           checkout_steps.first.fetch('with', {})['persist-credentials'] == false
      failures << "#{ci_workflow} must structurally keep one pinned credential-free checkout step"
    end
    unless ruby_steps.length == 1 &&
           ruby_steps.first['uses'] == 'ruby/setup-ruby@12fd324f1d0b43274fdc8130f6980590a667c455' &&
           ruby_steps.first.fetch('with', {})['ruby-version'] == '3.3'
      failures << "#{ci_workflow} must structurally keep one pinned Ruby 3.3 setup step"
    end
    unless steps.length == 3 &&
           steps[0] == checkout_steps.first &&
           steps[1] == ruby_steps.first &&
           steps[2] == run_steps.first &&
           steps.none? { |step| step.key?('if') || step.key?('continue-on-error') }
      failures << "#{ci_workflow} must structurally keep exactly checkout, Ruby setup, and make check steps"
    end
  rescue Psych::Exception, NoMethodError, TypeError => error
    failures << "#{ci_workflow} must parse as the expected workflow structure: #{error.message}"
  end
end

workflow_files = Dir[File.join(workflow_dir, '*.{yml,yaml}')].sort
unless workflow_files == [ci_workflow]
  failures << "#{workflow_dir} must contain only check.yml"
end

if File.exist?(codeowners) && File.read(codeowners).strip != '* @garethpaul'
  failures << "#{codeowners} must assign all paths to @garethpaul"
end

vendored_manifest = 'app/libs/SHA256SUMS'
vendored_jars = Dir['app/libs/*.jar'].sort
if File.exist?(vendored_manifest)
  expected_digests = {}
  File.readlines(vendored_manifest, chomp: true).each do |line|
    match = line.match(/\A([a-f0-9]{64})  (app\/libs\/[^\s]+\.jar)\z/)
    if match
      failures << "#{vendored_manifest} lists #{match[2]} more than once" if expected_digests.key?(match[2])
      expected_digests[match[2]] = match[1]
    else
      failures << "#{vendored_manifest} contains invalid entry #{line.inspect}"
    end
  end
  unless expected_digests.keys.sort == vendored_jars
    failures << "#{vendored_manifest} must list every vendored JAR exactly once"
  end
  vendored_jars.each do |jar|
    expected = expected_digests[jar]
    if expected && Digest::SHA256.file(jar).hexdigest != expected
      failures << "#{jar} does not match its checked-in SHA-256 digest"
    end
  end
else
  failures << "#{vendored_manifest} is missing"
end

project_docs = {
  'README.md' => ['GitHub Actions', 'docs/plans/2026-06-10-ci-baseline.md', 'sensitive Logcat', 'caught exception messages', 'both auth and profile preferences', 'correlate OAuth callback request tokens', 'exact callback authority and path', 'consume each accepted request token once', 'clear stale request tokens before retry', 'both profile and auth preference commits before authenticated navigation', logout_credential_plan, oauth_callback_plan, make_root_plan, oauth_callback_address_plan, oauth_request_token_consumption_plan, oauth_request_token_retry_reset_plan, oauth_session_persistence_plan],
  'VISION.md' => ['GitHub Actions', 'sensitive Logcat', 'caught exception', 'both auth and profile preferences', 'correlate OAuth callback request tokens', 'clear stale request tokens before retry', 'both profile and auth preference commits before authenticated navigation'],
  'SECURITY.md' => ['GitHub Actions', 'make check', 'sensitive Logcat', 'Caught exception objects', 'both auth and profile preferences', 'correlate OAuth callback request tokens', 'exact callback authority and path', 'consume each accepted request token once', 'clear stale request tokens before retry', 'both profile and auth preference commits before authenticated navigation'],
  'CHANGES.md' => ['GitHub Actions', 'sensitive Logcat', 'caught exception payloads', 'both auth and profile preferences', 'correlate OAuth callback request tokens', 'exact callback authority and path', 'consume each accepted request token once', 'clear stale request tokens before retry', 'both profile and auth preference commits before authenticated navigation']
}

project_docs.each do |path, required_phrases|
  if File.exist?(path)
    text = File.read(path)
    normalized_text = text.gsub(/\s+/, ' ')
    required_phrases.each do |phrase|
      failures << "#{path} must document #{phrase}" unless normalized_text.include?(phrase)
    end
  else
    failures << "#{path} is missing"
  end
end

['README.md', 'VISION.md', 'SECURITY.md', 'CHANGES.md'].each do |path|
  normalized_text = File.read(path).gsub(/\s+/, ' ')
  unless normalized_text.include?('invalidate pending timeline publications')
    failures << "#{path} must document Home timeline lifecycle invalidation"
  end
end
['README.md', 'VISION.md', 'SECURITY.md', 'CHANGES.md'].each do |path|
  normalized_text = File.read(path).gsub(/\s+/, ' ')
  unless normalized_text.include?('invalidate pending profile image publications')
    failures << "#{path} must document Home profile image lifecycle invalidation"
  end
end
unless File.read('README.md').include?(home_lifecycle_plan)
  failures << "README.md must index #{home_lifecycle_plan}"
end
unless File.read('README.md').include?(profile_image_plan)
  failures << "README.md must index #{profile_image_plan}"
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

sensitive_log_patterns = {
  /Log\.[a-z]+\s*\([^;]*\.getAll\s*\(\s*\)/m => 'complete preference maps',
  /Log\.[a-z]+\s*\([^;]*\b(?:username|profile_pic|access_token|access_token_secret)\b/m => 'profile or credential values',
  /Log\.[a-z]+\s*\([^;]*\b(?:statuses|tweet_holder)\.toString\s*\(\s*\)/m => 'timeline or tweet collections',
  /Log\.[a-z]+\s*\([^;]*\b\w+\.getMessage\s*\(\s*\)/m => 'dynamic login failure details'
}

%w[
  app/src/main/java/com/example/app/MainActivity.java
  app/src/main/java/com/example/app/HomeActivity.java
].each do |path|
  source = File.read(path)
  source_without_comments = source.gsub(%r{/\*.*?\*/}m, '').gsub(%r{//[^\n]*}, '')
  sensitive_log_patterns.each do |pattern, description|
    if source_without_comments.match?(pattern)
      failures << "#{path} must not write #{description} to sensitive Logcat output"
    end
  end
end

Dir['app/src/main/java/**/*.java'].sort.each do |path|
  source = File.read(path)
  code_without_strings = source
    .gsub(/"(?:\\.|[^"\\])*"/m, '""')
    .gsub(/'(?:\\.|[^'\\])*'/m, "''")
  code = code_without_strings.gsub(%r{/\*.*?\*/}m, '').gsub(%r{//[^\n]*}, '')
  if code.match?(/\.printStackTrace\s*\(/)
    failures << "#{path} must not write exception stack traces to Logcat"
  end

  log_expressions = code.split(';').map do |statement|
    log_start = statement.index(/(?:android\.util\.)?Log\.[a-z]+\s*\(/)
    next unless log_start

    expression = statement[log_start..-1]
    arguments_start = expression.index('(')
    expression[(arguments_start + 1)..-1]
  end.compact
  catch_variables = code.scan(
    /catch\s*\(\s*(?:final\s+)?[\w.$<>\[\]?]+(?:\s*\|\s*[\w.$<>\[\]?]+)*\s+(\w+)\s*\)/
  ).flatten.uniq
  catch_variables.each do |variable|
    variable_reference = /\b#{Regexp.escape(variable)}\b/
    if log_expressions.any? { |expression| expression.match?(variable_reference) }
      failures << "#{path} must not write caught exception #{variable} details to Logcat"
    end
  end
end

main_activity_path = 'app/src/main/java/com/example/app/MainActivity.java'
home_activity_path = 'app/src/main/java/com/example/app/HomeActivity.java'
main_activity_source = File.read(main_activity_path)
home_activity_source = File.read(home_activity_path)
main_activity_code = main_activity_source.gsub(%r{/\*.*?\*/}m, '').gsub(%r{//[^\n]*}, '')
home_activity_code = home_activity_source.gsub(%r{/\*.*?\*/}m, '').gsub(%r{//[^\n]*}, '')

unless main_activity_code.include?('static final String AUTH_PREFS_NAME = "MyPref";') &&
       main_activity_code.include?('static final String PROFILE_PREFS_NAME = "TwitterProfile";') &&
       main_activity_code.include?('static final String PREF_KEY_OAUTH_TOKEN = "oauth_token";') &&
       main_activity_code.include?('static final String PREF_KEY_OAUTH_SECRET = "oauth_token_secret";') &&
       main_activity_code.include?('static final String PREF_KEY_TWITTER_LOGIN = "boolean";')
  failures << "#{main_activity_path} must keep one shared set of auth and profile preference constants"
end

session_clear = main_activity_code.match(
  /static\s+boolean\s+clearTwitterSession\s*\(\s*android\.content\.Context\s+context\s*\)\s*\{(?<body>.*?)^    \}/m
)
unless session_clear &&
       session_clear[:body].include?('PROFILE_PREFS_NAME, MODE_PRIVATE') &&
       session_clear[:body].include?('AUTH_PREFS_NAME, MODE_PRIVATE') &&
       session_clear[:body].scan(/\.edit\(\)\.clear\(\)\.commit\(\)/).length == 2 &&
       session_clear[:body].include?('return profileCleared && authCleared;')
  failures << "#{main_activity_path} must synchronously clear both profile and auth preferences on logout"
end

session_persistence = main_activity_code.match(
  /static\s+boolean\s+persistTwitterSession\s*\(.*?\)\s*\{(?<body>.*?)^    \}/m
)
if session_persistence
  persistence_body = session_persistence[:body]
  profile_commit = persistence_body.index('boolean profileSaved = profileEditor.commit();')
  auth_commit = persistence_body.index('boolean authSaved = authEditor.commit();')
  profile_failure = persistence_body.index('if (!profileSaved)')
  auth_failure = persistence_body.index('if (!authSaved)')
  cleanup_calls = persistence_body.scan(/clearTwitterSession\(context\);/).length
  unless persistence_body.include?('PROFILE_PREFS_NAME, MODE_PRIVATE') &&
         persistence_body.include?('AUTH_PREFS_NAME, MODE_PRIVATE') &&
         persistence_body.include?('profileEditor.putString("username", username);') &&
         persistence_body.include?('authEditor.putString(PREF_KEY_OAUTH_TOKEN, oauthToken);') &&
         persistence_body.include?('authEditor.putString(PREF_KEY_OAUTH_SECRET, oauthSecret);') &&
         persistence_body.include?('authEditor.putBoolean(PREF_KEY_TWITTER_LOGIN, true);') &&
         profile_commit && auth_commit && profile_failure && auth_failure &&
         profile_commit < profile_failure && profile_failure < auth_commit && auth_commit < auth_failure &&
         cleanup_calls == 2 && persistence_body.include?('return true;')
    failures << "#{main_activity_path} must require both preference commits and purge partial OAuth sessions"
  end
else
  failures << "#{main_activity_path} must keep persistTwitterSession for OAuth session durability"
end

session_integrity = main_activity_code.match(
  /static\s+boolean\s+hasPersistedTwitterSession\s*\(.*?\)\s*\{(?<body>.*?)^    \}/m
)
if session_integrity
  integrity_body = session_integrity[:body]
  unless integrity_body.include?('AUTH_PREFS_NAME, MODE_PRIVATE') &&
         integrity_body.include?('getBoolean(PREF_KEY_TWITTER_LOGIN, false)') &&
         integrity_body.include?('getString(PREF_KEY_OAUTH_TOKEN, "")') &&
         integrity_body.include?('getString(PREF_KEY_OAUTH_SECRET, "")') &&
         integrity_body.include?('oauthToken != null && oauthToken.trim().length() > 0') &&
         integrity_body.include?('oauthSecret != null && oauthSecret.trim().length() > 0') &&
         integrity_body.match?(/return\s+loggedIn\s*&&/)
    failures << "#{main_activity_path} must require the login flag and complete OAuth token pair"
  end
else
  failures << "#{main_activity_path} must define hasPersistedTwitterSession"
end

unless main_activity_code.match?(
  /private\s+boolean\s+isTwitterLoggedInAlready\s*\(\s*\)\s*\{.*?return\s+hasPersistedTwitterSession\(getApplicationContext\(\)\);.*?^    \}/m
)
  failures << "#{main_activity_path} must use complete persisted-session integrity before login navigation"
end

home_session_guard = home_activity_code.match(
  /if\s*\(\s*!MainActivity\.hasPersistedTwitterSession\(getApplicationContext\(\)\)\s*\)\s*\{(?<body>.*?)\}/m
)
home_on_create = home_activity_code.index('public void onCreate(Bundle savedInstanceState)')
home_guard_index = home_activity_code.index('!MainActivity.hasPersistedTwitterSession')
home_content_index = home_activity_code.index('setContentView(R.layout.activity_home)')
if home_session_guard
  guard_body = home_session_guard[:body]
  unless guard_body.include?('MainActivity.clearTwitterSession(getApplicationContext());') &&
         guard_body.include?('startActivity(new Intent(getApplicationContext(), MainActivity.class));') &&
         guard_body.include?('finish();') && guard_body.include?('return;') &&
         home_on_create && home_guard_index && home_content_index &&
         home_on_create < home_guard_index && home_guard_index < home_content_index
    failures << "#{home_activity_path} must redirect and terminate incomplete sessions before Home initialization"
  end
else
  failures << "#{home_activity_path} must reject incomplete persisted sessions"
end

if File.exist?(oauth_session_integrity_plan)
  integrity_plan = File.read(oauth_session_integrity_plan)
  [
    'Status: Completed',
    'repository and external-directory `make check` passed',
    'hostile session-integrity mutations were rejected',
    'generated-artifact and credential-pattern audits passed'
  ].each do |evidence|
    failures << "#{oauth_session_integrity_plan} must record verification evidence #{evidence.inspect}" unless integrity_plan.include?(evidence)
  end
end

session_integrity_docs = {
  'README.md' => 'Authenticated entry requires the stored login flag plus a nonempty OAuth token and secret',
  'SECURITY.md' => 'Treat a stored session as authenticated only when the login flag and both OAuth token values are present',
  'VISION.md' => 'Require complete persisted OAuth credentials before authenticated entry',
  'CHANGES.md' => 'Required the persisted login flag and complete OAuth token pair before Main or Home can enter the authenticated flow'
}
session_integrity_docs.each do |path, contract|
  normalized = File.read(path).split.join(' ')
  failures << "#{path} must document persisted OAuth session integrity" unless normalized.include?(contract)
end

persistence_gate = main_activity_code.index('if (!persistTwitterSession(getApplicationContext(), username,')
persistence_failure = main_activity_code.index('Log.e(TAG, "Failed to store Twitter session");')
authenticated_navigation = main_activity_code.index('startActivity(goToNextActivity);')
unless persistence_gate && persistence_failure && authenticated_navigation &&
       persistence_gate < persistence_failure && persistence_failure < authenticated_navigation &&
       main_activity_code.match?(/if\s*\(\s*!persistTwitterSession\(.*?\)\s*\)\s*\{\s*Log\.e\(TAG, "Failed to store Twitter session"\);\s*return;/m)
  failures << "#{main_activity_path} must stop authenticated navigation when OAuth session persistence fails"
end

unless main_activity_code.match?(/if\s*\(\s*!clearTwitterSession\(getApplicationContext\(\)\)\s*\)\s*\{\s*Log\.e\(TAG, "Failed to clear Twitter session"\);\s*return;/m) &&
       home_activity_code.match?(/if\s*\(\s*!MainActivity\.clearTwitterSession\(getApplicationContext\(\)\)\s*\)\s*\{\s*Log\.e\(TAG, "Failed to clear Twitter session"\);\s*return;/m)
  failures << 'both logout flows must stop navigation when credential purge fails'
end

home_logout = home_activity_code.match(
  /private\s+void\s+logoutFromTwitter\s*\(\s*\)\s*\{(?<body>.*?)^    \}/m
)
if home_logout
  logout_body = home_logout[:body]
  clear_call = logout_body.index('MainActivity.clearTwitterSession(getApplicationContext())')
  failure_return = logout_body.index('return;')
  login_navigation = logout_body.index('startActivity(goToNextActivity);')
  revoke_home = logout_body.index('finish();')
  unless clear_call && failure_return && login_navigation && revoke_home &&
         clear_call < failure_return && failure_return < login_navigation && login_navigation < revoke_home
    failures << "#{home_activity_path} must revoke Home from the back stack only after successful logout navigation"
  end
else
  failures << "#{home_activity_path} must keep logoutFromTwitter for back-stack revocation"
end

if File.exist?(logout_back_stack_plan)
  logout_back_stack_evidence = File.read(logout_back_stack_plan)
  [
    'Status: Completed',
    'repository and external-directory `make check` passed',
    'hostile logout back-stack mutations were rejected',
    'generated-artifact and credential-pattern audits passed',
    'Exact diff'
  ].each do |evidence|
    failures << "#{logout_back_stack_plan} must record verification evidence #{evidence.inspect}" unless logout_back_stack_evidence.include?(evidence)
  end
end

logout_back_stack_docs = {
  'README.md' => 'remove the authenticated Home activity from the back stack',
  'SECURITY.md' => 'remove the authenticated Home activity from the back stack',
  'VISION.md' => 'remove the authenticated Home activity from the back stack',
  'CHANGES.md' => 'remove the authenticated Home activity from the back stack'
}
logout_back_stack_docs.each do |path, contract|
  failures << "#{path} must document logout back-stack revocation" unless File.read(path).split.join(' ').include?(contract)
end

if main_activity_code.include?('editor.putString("token"') ||
   main_activity_code.include?('editor.putString("secret"') ||
   home_activity_code.include?('getString("token"') ||
   home_activity_code.include?('getString("secret"')
  failures << 'OAuth tokens must not be duplicated into profile preferences'
end

unless home_activity_code.include?('MainActivity.AUTH_PREFS_NAME, Context.MODE_PRIVATE') &&
       home_activity_code.include?('MainActivity.PREF_KEY_OAUTH_TOKEN, ""') &&
       home_activity_code.include?('MainActivity.PREF_KEY_OAUTH_SECRET, ""') &&
       home_activity_code.include?('MainActivity.PROFILE_PREFS_NAME, Context.MODE_PRIVATE')
  failures << "#{home_activity_path} must read profile and OAuth values from their dedicated private stores"
end

if home_activity_code.match?(/PREF_KEY_(?:OAUTH_TOKEN|OAUTH_SECRET|TWITTER_LOGIN)\s*=\s*""/) ||
   home_activity_code.match?(/getSharedPreferences\s*\([^,]+,\s*0\s*\)/)
  failures << "#{home_activity_path} must not restore empty preference keys or numeric preference modes"
end

callback_validator = main_activity_code.match(
  /static\s+boolean\s+isExpectedOAuthCallback\s*\(\s*Uri\s+uri\s*,\s*RequestToken\s+expectedRequestToken\s*\)\s*\{(?<body>.*?)^    \}/m
)
unless callback_validator &&
       callback_validator[:body].include?('uri == null || expectedRequestToken == null') &&
       callback_validator[:body].include?('Uri.parse(TWITTER_CALLBACK_URL)') &&
       callback_validator[:body].include?('getQueryParameter(URL_TWITTER_OAUTH_TOKEN)') &&
       callback_validator[:body].include?('getQueryParameter(URL_TWITTER_OAUTH_VERIFIER)') &&
       callback_validator[:body].include?('configuredCallback.getScheme().equals(uri.getScheme())') &&
       callback_validator[:body].include?('configuredCallback.getAuthority().equals(uri.getAuthority())') &&
       callback_validator[:body].include?('configuredCallback.getEncodedPath().equals(uri.getEncodedPath())') &&
       callback_validator[:body].include?('expectedToken.equals(callbackToken)') &&
       callback_validator[:body].include?('verifier.trim().length() > 0')
  failures << "#{main_activity_path} must correlate the exact OAuth callback address with the active request token and verifier"
end

if File.exist?(oauth_callback_address_plan)
  callback_address_plan = File.read(oauth_callback_address_plan)
  [
    'Status: Completed',
    'repository and external-directory `make check` passed',
    'hostile callback-address mutations were rejected',
    'generated-artifact and credential-pattern audits passed'
  ].each do |evidence|
    failures << "#{oauth_callback_address_plan} must record verification evidence #{evidence.inspect}" unless callback_address_plan.include?(evidence)
  end
end

callback_gate = main_activity_code.index('if (!isExpectedOAuthCallback(uri, requestToken))')
callback_token_copy = main_activity_code.index('RequestToken callbackRequestToken = requestToken;')
callback_token_clear = main_activity_code.index('requestToken = null;')
access_token_exchange = main_activity_code.index('twitter.getOAuthAccessToken(')
unless callback_gate && callback_token_copy && callback_token_clear && access_token_exchange &&
       callback_gate < callback_token_copy && callback_token_copy < callback_token_clear &&
       callback_token_clear < access_token_exchange &&
       main_activity_code.include?('callbackRequestToken, verifier') &&
       main_activity_code.include?('Log.e(TAG, "Rejected invalid Twitter callback");') &&
       !main_activity_code.include?('uri.toString().startsWith(TWITTER_CALLBACK_URL)')
  failures << "#{main_activity_path} must consume an accepted OAuth request token before exchange"
end

if File.exist?(oauth_request_token_consumption_plan)
  token_plan = File.read(oauth_request_token_consumption_plan)
  ['Status: Completed', 'repository and external-directory `make check` passed', 'hostile request-token mutations were rejected'].each do |evidence|
    failures << "#{oauth_request_token_consumption_plan} must record verification evidence #{evidence.inspect}" unless token_plan.include?(evidence)
  end
end

login_flow = main_activity_code.match(
  /private\s+void\s+loginToTwitter\s*\(\s*\)\s*\{(?<body>.*?)^    \}/m
)
if login_flow
  retry_body = login_flow[:body]
  reset = retry_body.index('requestToken = null;')
  configure = retry_body.index('ConfigurationBuilder builder = new ConfigurationBuilder();')
  acquire = retry_body.index('RequestToken newRequestToken = twitter')
  publish = retry_body.index('requestToken = newRequestToken;')
  navigate = retry_body.index('newRequestToken.getAuthenticationURL()')
  unless reset && configure && acquire && publish && navigate &&
         reset < configure && configure < acquire && acquire < publish && publish < navigate &&
         retry_body.include?('.getOAuthRequestToken(TWITTER_CALLBACK_URL)') &&
         !retry_body.include?('requestToken = twitter') &&
         !retry_body.include?('requestToken.getAuthenticationURL()')
    failures << "#{main_activity_path} must clear stale request tokens before retry and publish only a successful local token"
  end
else
  failures << "#{main_activity_path} must keep loginToTwitter for OAuth retry validation"
end

if File.exist?(oauth_request_token_retry_reset_plan)
  retry_plan = File.read(oauth_request_token_retry_reset_plan)
  [
    'Status: Completed',
    'repository and external-directory `make check` passed',
    'hostile retry-reset mutations were rejected',
    'generated-artifact and credential-pattern audits passed'
  ].each do |evidence|
    failures << "#{oauth_request_token_retry_reset_plan} must record verification evidence #{evidence.inspect}" unless retry_plan.include?(evidence)
  end
end

if File.exist?(oauth_session_persistence_plan)
  persistence_plan = File.read(oauth_session_persistence_plan)
  [
    'Status: Completed',
    'repository and through the absolute Makefile path from `/tmp`',
    'Six isolated hostile mutations were rejected',
    'Android Gradle execution remains outside the Linux static legacy boundary',
    'git diff --check'
  ].each do |evidence|
    failures << "#{oauth_session_persistence_plan} must record verification evidence #{evidence.inspect}" unless persistence_plan.include?(evidence)
  end
end

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
  unless utils_source.include?('Log.e(TAG, "Failed to copy stream");')
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
         image_loader_source.match?(/if\s*\(\s*!\s*copied\s*\)\s*\{\s*deleteQuietly\(f\);\s*return null;\s*\}/m)
    failures << "#{image_loader_path} must stop decoding when an image cache write fails"
  end
  unless image_loader_source.include?('deleteQuietly(f);') &&
         image_loader_source.include?('Failed to delete partial image cache file')
    failures << "#{image_loader_path} must delete partial image cache files after failed writes"
  end
  unless image_loader_source.include?('Log.e(TAG, "Failed to load image");')
    failures << "#{image_loader_path} must log image load IOException failures"
  end
  unless image_loader_source.match?(/catch\s*\(\s*IOException\s+ex\s*\)\s*\{[^}]*Log\.e\(TAG, "Failed to load image"\);[^}]*deleteQuietly\(f\);[^}]*return null;/m)
    failures << "#{image_loader_path} must delete partial cache files after image download exceptions"
  end
  unless image_loader_source.match?(/Bitmap bitmap = decodeFile\(f\);\s*if\s*\(bitmap == null\)\s*\{\s*deleteQuietly\(f\);\s*return null;\s*\}/m)
    failures << "#{image_loader_path} must delete downloaded cache files that fail bitmap decoding"
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
  unless image_loader_source.include?('Log.e(TAG, "Failed to decode cached image");')
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
  unless home_activity_source.include?('Log.e(TAG, "Failed to download profile image");')
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
