# Vendored SDK Integrity

Status: Completed

## Context

The sample archives four third-party SDK JARs directly under `app/libs`. Their
versions are old, they are not resolved through a package manager, and their
contents previously had no repository-level integrity record. The Android
Gradle Plugin 0.8.3, Gradle 1.10, and SDK 19 build remain archival and are not a
credible modern hosted build target.

## Objectives

- Record the exact SHA-256 digest of every vendored JAR.
- Fail the static contract if a JAR changes, appears, or disappears unnoticed.
- Keep hosted validation structural and dependency-free.
- Fix the CI runner and preserve immutable action revisions.
- Make `make check` independent of the caller's working directory.

## Work Completed

- Added `app/libs/SHA256SUMS` covering all four vendored SDK JARs.
- Extended the Ruby contract to validate manifest syntax, file coverage, and
  file contents.
- Fixed GitHub Actions to Ubuntu 24.04 with concurrency cancellation.
- Annotated the reviewed checkout v6.0.3 and setup-ruby v1.312.0 commits.
- Anchored Makefile and checker execution to the repository root.

## Verification

- `make check`
- `make -f /path/to/repository/Makefile check` from outside the repository
- `sha256sum -c app/libs/SHA256SUMS`
- `git diff --check`
