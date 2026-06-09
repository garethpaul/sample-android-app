# Changes

## 2026-06-09

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
