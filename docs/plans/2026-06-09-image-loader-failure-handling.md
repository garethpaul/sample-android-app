# Image Loader Failure Handling

## Status: Completed

## Context

`ImageLoader.getBitmap()` downloaded images into the internal cache but caught a
broad `Exception`, printed stack traces, and then rounded the decoded bitmap
without checking whether decoding succeeded. Network or cache failures should
be logged through Android's logger and failed decodes should leave the
placeholder image in place.

## Objectives

- Keep image downloads and internal cache behavior unchanged for successful
  loads.
- Replace broad stack-trace handling with tagged `IOException` logging.
- Close image download streams and disconnect HTTP connections.
- Guard failed bitmap decodes before creating rounded bitmaps.

## Work Completed

- Updated `ImageLoader` to catch `IOException` for image downloads and log
  `Failed to load image` with the class tag.
- Added quiet stream cleanup and HTTP disconnect handling.
- Returned `null` when cached image decode fails, preserving placeholder
  behavior.
- Extended `scripts/check_android_contract.rb` to reject broad image-load
  exception handling and require the decode guard.

## Verification

- `ruby scripts/check_android_contract.rb`
- `make check`
- `make verify`
- `git diff --check`

## Legacy Gradle Notes

This environment used the default static verification path. `make check` still
supports `RUN_LEGACY_GRADLE=1` on a machine with a compatible legacy Android
SDK.
