# Disable App Backup

## Status: Completed

## Context

`sample-android-app` is a legacy OAuth and ad-network sample. The checked-in
manifest enabled Android app backup, which is a poor default for a credential-
adjacent sample because local runtime state can include account or session data.

## Objectives

- Disable Android app backup in the manifest.
- Extend the static Android contract checker so backup cannot be re-enabled
  silently.
- Document the privacy-oriented manifest guard in project maintenance notes.
- Keep verification available through `make check` without requiring a legacy
  Android SDK.

## Work Completed

- Set `android:allowBackup="false"` in `app/src/main/AndroidManifest.xml`.
- Added a static manifest assertion to `scripts/check_android_contract.rb`.
- Updated README, VISION, and CHANGES.

## Verification

- `ruby scripts/check_android_contract.rb`
- `make check`
- `make verify`
- `git diff --check`

## Follow-Up Candidates

- Review exported activities and OAuth callback handling in a dedicated
  manifest-compatibility pass.
- Document which permissions are required for the historical ad SDKs and which
  can be removed for a local demo.
