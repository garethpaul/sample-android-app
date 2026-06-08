# Copy Stream Error Handling

## Problem

`Utils.CopyStream` caught broad `Exception` and ignored it. That made read and
write failures indistinguishable from successful image-cache copies and removed
the only diagnostic signal available in this legacy Android sample.

## TDD Evidence

1. Extended `scripts/check_android_contract.rb` to fail when the stream-copy
   helper catches broad `Exception`, omits the expected `IOException` handler,
   or skips the Android error log call.
2. Replaced the swallowed broad handler with a narrow `IOException` handler
   that logs the copy failure through `Log.e`.
3. Updated the bug note, changelog, README, and vision guardrail to document the
   observable-error contract.

## Verification

- `make lint`
- `make verify`
- `git diff --check`

The default build target remains static because this project uses a legacy
Android Gradle stack. Set `RUN_LEGACY_GRADLE=1` on a workstation with a
compatible Android SDK to attempt the full Android build.
