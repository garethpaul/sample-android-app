# Changes

## 2026-06-08

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
