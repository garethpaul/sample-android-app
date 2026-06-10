# CI Baseline

Status: Completed

## Context

The repository had a local Ruby-backed `make check` contract for the legacy
Android sample, but no hosted workflow ran it for pushes and pull requests.
The obsolete Gradle and Android SDK stack is intentionally not executed on
modern hosted runners, while its source and security contracts remain
independently enforceable.

## Changes

- Added a GitHub Actions workflow that installs Ruby 3.3 and runs `make check`.
- Pinned checkout and Ruby setup actions by verified commit SHA.
- Restricted workflow permissions to read-only contents and bounded the job to
  five minutes.
- Extended the Android contract checker and docs so future changes keep the
  hosted CI baseline visible.

## Verification

- `ruby -c scripts/check_android_contract.rb`
- `make check`
- `git diff --check`
