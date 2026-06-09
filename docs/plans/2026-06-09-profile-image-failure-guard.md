# Profile Image Failure Guard

## Status: Completed

## Context

`HomeActivity.GetXMLTask` downloads and rounds the stored Twitter profile image.
That path still printed stack traces, swallowed broad connection failures, and
rounded the bitmap without guarding failed downloads or decodes. The separate
`ImageLoader` path already had tagged logging and failed-decode guards; the
profile image path should follow the same standard.

## Objectives

- Keep the legacy profile image rendering behavior for successful downloads.
- Replace stack traces with tagged Android error logging.
- Return the placeholder image when profile image downloads or decodes fail.
- Add static validation for the guarded profile image path.

## Work Completed

- Logged tweet-fetch and profile-image failures with `Log.e`.
- Added null stream and null bitmap guards before rounded bitmap rendering.
- Closed the profile image stream in a `finally` block and logged close
  failures.
- Removed broad connection exception handling from `getHttpConnection`.
- Extended `scripts/check_android_contract.rb` to reject stack traces and
  require profile image failure handling.
- Updated README, VISION, and CHANGES notes for the profile image guard.

## Verification

- `ruby scripts/check_android_contract.rb`
- `make check`
- `git diff --check`
