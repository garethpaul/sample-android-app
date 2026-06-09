# IDE Metadata Ignore

## Status: Completed

## Context

The legacy Android sample still tracked IntelliJ `.idea` files and module
`.iml` files. Those files capture local IDE state and generated dependency
metadata that should not be part of a portable sample app.

## Objectives

- Remove tracked IntelliJ and module metadata.
- Ignore `.idea/` and `*.iml` files for future local editor state.
- Preserve Android source, vendored libraries, wrapper files, and sample assets.
- Extend the SDK-free static contract checker so IDE metadata does not return.

## Work Completed

- Removed checked-in `.idea` metadata and module `.iml` files.
- Added `.idea/` and `*.iml` to `.gitignore`.
- Extended `scripts/check_android_contract.rb` to reject tracked IDE metadata.
- Updated README, VISION, and CHANGES.

## Verification

- `ruby scripts/check_android_contract.rb`
- `make check`
- `git diff --check`

## Legacy Gradle Notes

This environment used the default SDK-free static verification path. `make
check` still supports `RUN_LEGACY_GRADLE=1` on a machine with a compatible
legacy Android SDK.

## Follow-Up Candidates

- Document a known-good Android Studio import path during a dedicated setup
  documentation pass.
- Modernize Gradle and dependencies separately before relying on IDE-generated
  metadata.
