# CI Baseline

Status: Completed

## Context

The repository had a local Ruby-backed `make check` contract for the legacy
Android sample, but no hosted workflow ran it for pushes and pull requests.

## Changes

- Added a GitHub Actions workflow that installs Ruby 3.3 and runs `make check`.
- Extended the Android contract checker and docs so future changes keep the
  hosted CI baseline visible.

## Verification

- `make check`
