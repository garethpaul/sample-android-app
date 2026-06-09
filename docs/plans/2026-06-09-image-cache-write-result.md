# Image Cache Write Result Guard

## Status: Completed

## Context

`ImageLoader.getBitmap()` writes downloaded tweet images into the app-internal
cache before decoding them for rounded rendering. `Utils.CopyStream()` logged
copy failures but returned `void`, so callers could not tell whether a cache
file was complete before decoding it.

## Objectives

- Preserve existing image rendering and placeholder behavior for successful
  loads.
- Make stream-copy success explicit to callers.
- Stop decoding image cache files after failed writes.
- Delete partial image cache files when a copy fails.
- Add static verification so future image-cache changes keep this contract.

## Work Completed

- Changed `Utils.CopyStream()` to return `true` after a complete copy and
  `false` after an `IOException`.
- Updated `ImageLoader` to branch on the copy result, delete failed cache
  writes, and keep the placeholder path for failures.
- Extended `scripts/check_android_contract.rb` to require the stream-copy
  result contract and partial-cache cleanup.
- Updated README, VISION, and CHANGES.

## Verification

- Negative: `ruby scripts/check_android_contract.rb` failed before the Java fix
  because stream-copy completion was not reported and failed cache writes were
  still decoded.
- `ruby scripts/check_android_contract.rb`
- `make check`
- `make verify`
- `git diff --check`

## Follow-Up Candidates

- Add deterministic JVM tests if the project is migrated to a modern Android
  Gradle plugin.
- Consider replacing hash-code cache filenames with a stable URL digest in a
  dedicated compatibility pass.
