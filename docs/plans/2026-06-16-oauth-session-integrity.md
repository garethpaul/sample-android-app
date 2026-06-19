# OAuth Session Integrity

Status: Completed

## Problem

The login activity trusts only the stored login boolean, and `HomeActivity`
starts authenticated work without revalidating the stored token pair. A stale
true flag with a missing OAuth token or secret can therefore enter the
authenticated UI and construct an incomplete access token.

## Requirements

1. Treat a persisted session as authenticated only when the login flag, OAuth
   token, and OAuth secret are all present.
2. Apply the same complete-session check before `HomeActivity` starts ads,
   profile image loading, or timeline work.
3. Redirect incomplete Home sessions to login after best-effort full-session
   cleanup and stop all remaining Home initialization.
4. Preserve callback correlation, one-shot request-token consumption, retry
   reset, commit-gated persistence, logout cleanup, and sanitized logging.

## Scope Boundaries

- Do not change OAuth endpoints, consumer configuration, callback routing,
  manifests, dependencies, vendored JARs, or UI layout.
- Do not add token refresh, encryption, migration, asynchronous storage, or new
  persistence dependencies.
- Keep this change stacked on PR #11; do not merge or close the stack without
  explicit owner authorization.

## Verification Plan

- Run the focused static Android contract and complete `make check` gate from
  the repository and an external directory.
- Reject isolated mutations for boolean-only login, missing token/secret
  checks, Home entry bypass, missing redirect termination, guidance, and plan
  evidence.
- Audit the exact diff, secrets, generated artifacts, dependencies, vendored
  binaries, conflicts, modes, and whitespace before commit and push.

## Work Completed

- Added one complete persisted-session predicate requiring the login flag,
  OAuth token, and OAuth secret.
- Routed Main login-state navigation through the complete predicate.
- Rejected incomplete Home sessions before layout, ads, image loading, or
  timeline work; cleanup is attempted before redirect and termination.
- Added mutation-sensitive static contracts and synchronized maintenance
  guidance.

## Verification Completed

- The focused Android contract passed.
- The repository and external-directory `make check` passed.
- Seven hostile session-integrity mutations were rejected across the login
  flag, token and secret checks, Home entry guard, redirect termination,
  guidance, and completed-plan evidence.
- The exact eight-file implementation diff passed whitespace, secret,
  dependency, vendored-binary, conflict-marker, mode, and intended-path audits.
- The generated-artifact and credential-pattern audits passed.
- Android Gradle execution remains outside the Linux static legacy boundary;
  no SDK-dependent runtime behavior is claimed.
