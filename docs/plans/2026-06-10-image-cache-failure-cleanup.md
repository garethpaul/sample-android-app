# Image Cache Failure Cleanup

## Status: Completed

## Context

The image loader deleted cache files when stream copying returned `false`, but
an `IOException` returned from inside the catch block before that cleanup. A
download that copied successfully but was not a decodable image also remained
in the app-internal cache.

## Objectives

- Delete partial cache files after download exceptions.
- Delete completed downloads that fail bitmap decoding.
- Preserve successful cache and placeholder behavior.

## Work Completed

- Added cache cleanup to the image download `IOException` path.
- Added cleanup when the downloaded file cannot be decoded as a bitmap.
- Extended the dependency-free Android contract checker.
- Updated README, SECURITY, VISION, and CHANGES guidance.

## Verification

- `ruby scripts/check_android_contract.rb`
- `make check`
- `make verify`
- `git diff --check`

## Legacy Build Notes

The archived Gradle build remains opt-in through `RUN_LEGACY_GRADLE=1` on a
machine with a compatible Android SDK and the historical dependencies.
