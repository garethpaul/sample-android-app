# Image Cache Decode Cleanup

## Status: Completed

## Context

`ImageLoader.decodeFile()` opens cached image files twice: once for bounds
decoding and once for the scaled bitmap decode. Those `FileInputStream`s were
passed directly into `BitmapFactory.decodeStream()` and were not closed. The
method also silently swallowed `FileNotFoundException`, hiding cache drift.

## Objectives

- Close cached image decode streams for both bounds and bitmap decode passes.
- Keep existing placeholder behavior when cached image decode fails.
- Log missing cached image files through Android's logger instead of swallowing
  failures.
- Add static validation so future ImageLoader changes preserve the cleanup.

## Work Completed

- Added explicit bounds and bitmap decode stream variables.
- Closed both streams through the existing `closeQuietly()` helper.
- Logged cached image decode `FileNotFoundException` failures with the class
  tag.
- Extended `scripts/check_android_contract.rb` to require stream cleanup and
  decode failure logging.
- Updated README, VISION, and CHANGES notes for the decode cleanup guard.

## Verification

- `ruby scripts/check_android_contract.rb`
- `make check`
- `make verify`
- `git diff --check`

## Legacy Gradle Notes

This environment used the default static verification path. `make check` still
supports `RUN_LEGACY_GRADLE=1` on a machine with a compatible legacy Android
SDK.
