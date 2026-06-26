# Changes

## 2026-06-25T19:52:00-0700 — P1 lifecycle — profile image publication

- Bug fixed: the Home profile image `AsyncTask` could outlive successful logout
  or Activity teardown and publish into a destroyed screen.
- Lifecycle: each task now captures a publication revision; logout and teardown
  invalidate and cancel the active task before navigation or superclass teardown.
- Home teardown and successful logout invalidate pending profile image publications.
- Transport: profile image connections use 30-second connect/read timeouts,
  close their stream, and disconnect deterministically.
- Compatibility: current successful downloads still render rounded profile
  images, while current failures still render the placeholder.
- Tests: added a Java 7 publication harness, a Ruby source checker, and nine
  hostile mutations covering stale publication, lifecycle invalidation,
  cancellation, timeout, connection ownership, and disconnect boundaries.
- Validation: focused RED/GREEN tests pass; full repository verification follows.
- Next: run the complete repository gate, review the exact branch, and merge
  only after hosted checks pass.

## 2026-06-25T21:10:35Z — P1 privacy/correctness — cycle: Home timeline lifecycle

- Threads: inspected the explicit Apache 2.0 license, default branch, open pull
  requests and issues, hosted checks, OAuth session entry and logout, timeline
  refresh revision ownership, Activity teardown, profile image work, ad
  lifecycle, static contracts, Java harnesses, and hostile mutations.
- Bug fixed: successful logout and Home teardown now invalidate pending timeline
  publications before stale callbacks can replace visible account rows; teardown
  also destroys the initialized Home ad view.
- Files: `HomeActivity.java`, `TimelinePublication.java`, timeline source and
  mutation tests, Android contracts, lifecycle documentation, and
  `docs/plans/2026-06-25-home-timeline-lifecycle.md`.
- Validation: reproduced the missing invalidation API as a Java compile failure,
  then passed the Java 7 publication harness, source checker, and fourteen
  hostile timeline mutations.
- Blockers: the legacy Android SDK/Gradle application was not executed locally;
  hosted Ruby/JDK contract verification remains required before merge.
- Next: verify logout during a slow timeline fetch and Activity destruction in
  an emulator while observing that no stale adapter or ad callback is retained.

## 2026-06-25

- Replaced displayed timeline rows atomically after successful refreshes,
  preserved the previous rows after failures, and ignored stale overlapping
  completions without hiding the active request's loading state.
- Added SDK-free Java behavior tests, static source checks, and hostile mutation
  coverage for timeline publication and refresh wiring.

## 2026-06-21

- Isolated Make verification authority from caller-controlled file lists,
  shells, shell flags, Ruby variables, repository roots, and trailing target
  replacements, with explicit GNU Make preload-boundary coverage.

## 2026-06-17

- Made successful logout remove the authenticated Home activity from the back stack
  after credential clearing and login navigation.

## 2026-06-16

- Required the persisted login flag and complete OAuth token pair before Main
  or Home can enter the authenticated flow.
- Required both profile and auth preference commits before authenticated
  navigation and purged partial session state after persistence failure.

## 2026-06-15

- Made OAuth login clear stale request tokens before retry and publish only a
  successfully acquired replacement for callback correlation.

## 2026-06-14

- Made OAuth callbacks consume each accepted request token once before exchange,
  preventing in-memory callback replay after logout or failed exchange.

## 2026-06-13

- Required login to correlate OAuth callback request tokens with the active
  request, exact callback origin, and verifier before access-token exchange.
- Required the exported login flow to match the exact callback authority and path
  so alternate ports, user-info authorities, and paths cannot reach token exchange.
- Kept OAuth tokens out of profile metadata and made logout clear both auth and
  profile preferences before returning to the login screen.

## 2026-06-12

- Removed sensitive Logcat output for OAuth preference maps, profile values,
  timelines, and rendered tweet collections, with static contract coverage.
- Removed caught exception payloads and stack traces from Logcat while
  retaining fixed tagged failure events, with rename-resistant contract checks.

## 2026-06-10

- Deleted partial or undecodable image cache files after transport and bitmap
  decode failures, with static contract coverage.
- Added a least-privilege GitHub Actions workflow that installs Ruby 3.3 and
  runs `make check` with Node 24-compatible actions pinned by commit and a
  five-minute timeout.
- Disabled checkout credential persistence, validated every pushed branch,
  added CODEOWNERS, and made workflow policy fail closed.
- Extended the Android contract checker and docs to require the hosted CI
  verification path.
- Added SHA-256 integrity coverage for all four vendored SDK JARs.
- Fixed hosted static validation to Ubuntu 24.04 with concurrency cancellation.
- Made the Makefile and checker independent of the caller's directory.

## 2026-06-09

- Declared explicit manifest exported state for `MainActivity` and
  `HomeActivity`, with static checker coverage.
- Removed tracked IntelliJ `.idea` and `.iml` metadata with static checker
  coverage to keep local IDE files ignored.
- Guarded null and empty image URLs before cache lookup, preserving placeholder
  display and avoiding `url.hashCode()` crashes.
- Closed cached image decode streams and logged cache decode failures, with
  static validation for the ImageLoader path.
- Made image cache writes report copy success, and delete partial cache files
  before decoding when a download copy fails.
- Added tagged logging, null guards, stream cleanup, and placeholder fallback
  for profile image download failures.
- Replaced broad image-load stack traces with tagged `IOException` logging,
  HTTP/stream cleanup, and a failed-decode guard before bitmap rounding.
- Moved image caching to app-internal cache storage and removed default storage
  and coarse-location permissions from the manifest.
- Extended the Android contract checker to require the minimal network-only
  permission set and reject external-cache storage drift.

## 2026-06-08

- Removed duplicate `HomeActivity` launcher and OAuth callback intent filters,
  and added static manifest entrypoint validation.
- Disabled Android app backup in the manifest and added a static contract check
  to preserve the privacy guard.
- Added `make check` as the shared repository verification alias.
- Narrowed `Utils.CopyStream` failure handling to `IOException` and added
  Android error logging so stream-copy failures are observable.
- Extended the Android contract checker to reject broad swallowed exceptions in
  the stream-copy helper.
- Added a static Android contract check for wrapper safety, generated build
  outputs, local credential templates, and hardcoded ad-unit values.
- Replaced the compiled `Const_Example.java` placeholder with a copyable ignored
  `Const.java.example` template.
- Removed tracked generated `build/` outputs and expanded gitignore coverage.
- Switched the Gradle wrapper distribution URL to HTTPS and restored the
  executable bit on `gradlew`.
- Replaced dynamic legacy Gradle and appcompat dependency versions with pinned
  versions and removed missing javadoc/source jar dependencies.
- Moved the home-screen MoPub ad unit lookup to `Const.MoPubMiniBannerId`.
- Added canonical `docs/plans` coverage and made the Android contract checker
  require completed plans.
