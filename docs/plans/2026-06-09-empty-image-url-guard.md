# Empty Image URL Guard

## Status: Completed

## Context

`ImageLoader.DisplayImage` accepted the image URL and immediately queued cache
or network work. A null or empty URL could reach `FileCache.getFile(url)`,
where `url.hashCode()` would crash instead of leaving the placeholder image in
place.

## Objectives

- Preserve successful image loading and cache behavior.
- Show the placeholder image for null or empty image URLs.
- Avoid queueing cache or network work when no usable URL is present.
- Add static validation for the guard.

## Work Completed

- Added an early `DisplayImage` guard for `url == null || url.length() == 0`.
- Removed stale image-view mappings and set the placeholder before returning.
- Extended `scripts/check_android_contract.rb` to require the empty URL guard.
- Updated README, VISION, and CHANGES notes for the image URL guard.

## Verification

- `ruby scripts/check_android_contract.rb`
- `make lint`
- `make check`
- `make verify`
- `git diff --check`

## Legacy Gradle Notes

This environment used the default static verification path. `make check` still
supports `RUN_LEGACY_GRADLE=1` on a machine with a compatible legacy Android
SDK.
