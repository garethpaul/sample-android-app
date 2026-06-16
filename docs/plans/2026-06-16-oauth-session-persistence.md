# OAuth Session Persistence

Status: Completed

## Problem

The OAuth callback ignores both synchronous preference commit results and
navigates to the authenticated activity even when profile or credential state
was not stored. A partial failure can therefore expose a logged-in UI with an
incomplete or inconsistent local session.

## Requirements

1. Require both the profile and OAuth credential commits to succeed before
   authenticated navigation.
2. Purge both preference stores after either persistence failure so partial
   session state is not retained.
3. Preserve callback address/token correlation, one-shot request-token
   consumption, retry reset, credential separation, and sanitized logging.
4. Add mutation-sensitive static contracts, synchronized guidance, and
   truthful completed evidence.

## Scope Boundaries

- Do not change OAuth endpoints, consumer configuration, callback routing,
  manifests, dependencies, vendored JARs, or UI layout.
- Do not add asynchronous storage, retries, migration, encryption, or new
  persistence dependencies.
- Keep this change stacked on PR #10; do not merge or close either pull request
  without explicit owner authorization.

## Verification Plan

- Run the focused static Android contract and complete `make check` gate from
  the repository and an external directory.
- Reject isolated mutations of commit-result gating, cleanup, navigation
  ordering, guidance, and plan evidence.
- Audit the exact diff, secrets, generated artifacts, dependencies, vendored
  binaries, conflicts, modes, and whitespace before commit and push.

## Work Completed

- Added one synchronous persistence helper that commits profile data before
  OAuth credentials and returns success only after both stores succeed.
- Purged both preference stores and stopped navigation after either commit
  failure.
- Added mutation-sensitive static contracts, synchronized guidance, and this
  completed evidence record.

## Verification Completed

- The focused static Android contract and full `make check` gate passed from
  the repository and through the absolute Makefile path from `/tmp`.
- Six isolated hostile mutations were rejected across profile commit gating,
  auth commit gating, cleanup, navigation ordering, guidance, and plan status.
- The exact seven-file implementation diff passed `git diff --check`, secret,
  generated-artifact, dependency, vendored-binary, conflict-marker, mode, and
  intended-path audits.
- Android Gradle execution remains outside the Linux static legacy boundary;
  no SDK-dependent runtime behavior is claimed.
