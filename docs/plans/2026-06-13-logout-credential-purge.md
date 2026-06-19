# Logout Credential Purge

## Status: Completed

## Context

The legacy sample persisted the Twitter access token and secret in both
`MyPref` and `TwitterProfile`. `HomeActivity` logout cleared only `MyPref`, so
the active credential copy used for timeline requests remained on disk after
the UI returned to the login screen. The activity also declared empty local
preference keys, obscuring which values were actually removed.

## Priority

Logout is a security boundary. A successful logout must remove all retained
OAuth credentials and profile state before navigation, even in this archived
sample. The fix must remain compatible with API 7 and the historical Gradle
toolchain, where modern encrypted preference libraries are unavailable.

## Objectives

- Store access tokens only in the dedicated private auth preferences.
- Share preference names and OAuth keys between both activities.
- Clear both auth and profile preferences synchronously during logout.
- Stop logout navigation and emit only a fixed diagnostic if either purge
  fails.
- Add fail-closed source, documentation, and completed-plan contracts.
- Preserve the archived login, timeline, profile, and OAuth callback flow.

## Work Completed

- Centralized the auth preference name, profile preference name, and OAuth keys
  in `MainActivity` for use by both activities.
- Removed the duplicate token and secret copy from profile preferences.
- Updated `HomeActivity` timeline requests to read credentials only from the
  private auth preferences.
- Added a shared synchronous logout helper that clears both stores and reports
  whether both commits succeeded.
- Stopped both logout flows before navigation when credential purge fails.
- Added fail-closed source, documentation, and completed-plan contracts.

## Verification

- `ruby scripts/check_android_contract.rb`
- `make check` locally and from outside the repository root
- focused preference-name, token-duplication, dual-purge, failure-guard,
  documentation, and plan mutations
- workflow YAML, manifest XML, README SVG XML, and vendored JAR digest checks
- Java delimiter, generated-artifact, high-confidence secret, and
  `git diff --check` audits
- document the legacy Android SDK 19 binary-validation boundary

The Android contract checker and full `make check` passed locally and through
a root-independent Make invocation. Both runs reported only the documented
legacy Gradle build skip. All 13 focused preference-name, duplicate-token,
store-selection, dual-purge, failure-guard, success-semantics, numeric-mode,
empty-key, documentation, and plan-status mutations were rejected.

The workflow YAML, manifest XML, and both README SVG files parsed successfully.
All four vendored SDK JARs matched `app/libs/SHA256SUMS`; Java delimiter,
generated-artifact, high-confidence secret, and `git diff --check` audits also
passed. `ANDROID_HOME` and `adb` are unavailable, so binary, emulator, and
device validation against the historical Android SDK 19 stack remains skipped.

## Scope Boundary

This removes duplicate and post-logout credential retention but does not add
at-rest encryption or make the obsolete Twitter and Android dependencies safe
for production. Encrypted storage requires a separate compatibility migration.
