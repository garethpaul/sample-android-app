# Manifest Entrypoints

## Status: Completed

## Context

`sample-android-app` is a legacy OAuth and ad-network sample. The manifest
exposed both `MainActivity` and `HomeActivity` as launcher activities and as
handlers for the `oauth://t4jsample` callback. That creates duplicate launcher
surfaces and implicitly exports the home screen as a callback target.

## Objectives

- Keep the default verification path dependency-free.
- Preserve the login flow through `MainActivity`.
- Remove duplicate `HomeActivity` launcher and OAuth callback intent filters.
- Fail static verification if launcher or OAuth callback exposure drifts beyond
  `MainActivity`.
- Preserve existing credential, backup, build-output, and docs-plan checks.

## Work Completed

- Removed launcher and OAuth callback intent filters from `HomeActivity`.
- Extended `scripts/check_android_contract.rb` to parse the manifest and require
  only `MainActivity` for launch and `oauth://t4jsample` callback handling.
- Updated README, VISION, and CHANGES notes for the manifest entrypoint guard.

## Verification

- `ruby scripts/check_android_contract.rb`
- `make check`
- `make verify`
- `git diff --check`
