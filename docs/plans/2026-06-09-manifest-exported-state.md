# Manifest Exported State

## Status: Completed

## Context

The manifest already limits launcher and OAuth callback intent filters to
`MainActivity`, but the activity exported state was still implicit. Explicit
exported attributes make the login callback surface and internal home screen
boundary easier to review.

## Objectives

- Keep `MainActivity` exported for launcher and `oauth://t4jsample` callback
  handling.
- Keep `HomeActivity` non-exported because it has no external intent filter.
- Extend the SDK-free static checker so activity exported state cannot drift.
- Preserve the existing manifest entrypoint and permission guards.

## Work Completed

- Added `android:exported="true"` to `MainActivity`.
- Added `android:exported="false"` to `HomeActivity`.
- Extended `scripts/check_android_contract.rb` to require both exported states.
- Updated README, SECURITY, VISION, and CHANGES notes.

## Verification

- `ruby scripts/check_android_contract.rb`
- `make lint`
- `make check`
- `make verify`
- `git diff --check`

## Legacy Gradle Notes

This environment used the default SDK-free static verification path. `make
check` still supports `RUN_LEGACY_GRADLE=1` on a machine with a compatible
legacy Android SDK.
