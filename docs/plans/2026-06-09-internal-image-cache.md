# Internal Image Cache Permission Guard

## Status: Completed

## Context

`sample-android-app` is a legacy Twitter and ad-network Android sample. The
manifest requested shared external storage for image caching and coarse location
for legacy ad behavior, even though the default sample can keep downloaded
profile images in app-internal cache storage and avoid optional location access.

## Objectives

- Remove default storage and location permissions from the sample manifest.
- Keep image cache data under the app-internal cache directory.
- Add static verification so future changes do not reintroduce optional
  privacy-sensitive permissions without a dedicated rationale.

## Work Completed

- Changed `FileCache` to use `context.getCacheDir()` for image cache storage.
- Removed `WRITE_EXTERNAL_STORAGE` and `ACCESS_COARSE_LOCATION` from
  `AndroidManifest.xml`.
- Extended `scripts/check_android_contract.rb` to require the minimal
  network-only permission set and app-internal image cache storage.
- Documented the permission guard in README, VISION, and CHANGES.

## Verification

- `ruby scripts/check_android_contract.rb`
- `make check`
- `make verify`
- `git diff --check`

## Follow-Up Candidates

- Add an explicit opt-in plan if legacy ad-location targeting is restored.
- Replace deprecated connectivity APIs during a dedicated Android compatibility
  modernization pass.
