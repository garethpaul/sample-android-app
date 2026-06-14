# OAuth Callback Address Integrity

## Status: Completed

## Context

The OAuth callback validator checks the configured scheme and host, active
request token, and verifier. It does not compare the callback authority or
path, so addresses such as `oauth://t4jsample:444/other` can reach token
exchange when their query parameters match an active request.

## Priority

High security boundary. The exported callback activity should accept only the
exact address registered with the OAuth provider.

## Requirements

- Compare the callback scheme, authority, and encoded path exactly.
- Reject alternate ports, user-info authorities, and nonempty paths.
- Preserve active request-token correlation and nonblank verifier checks.
- Keep rejection before access-token exchange and fixed non-sensitive logging.
- Add fail-closed static and mutation-sensitive contracts.

## Scope Boundaries

- Do not change the registered callback URL, manifest exposure, OAuth
  provider, token storage, logout behavior, dependencies, or legacy SDK floor.

## Verification

- focused callback source-contract validation
- repository and external-directory `make check`
- hostile authority, path, token, ordering, test, and completed-plan mutations
- exact diff, generated-artifact, and credential-pattern audits

## Verification Results

- Focused callback source-contract validation passed with exact scheme,
  authority, encoded-path, request-token, verifier, and exchange-order checks.
- The repository and external-directory `make check` passed after this
  completed status was recorded.
- Seven hostile callback-address mutations were rejected across authority,
  encoded path, scheme, token, verifier, exchange ordering, and completed-plan
  evidence.
- Final generated-artifact and credential-pattern audits passed with only the
  intended callback, checker, documentation, and completed-plan changes.
