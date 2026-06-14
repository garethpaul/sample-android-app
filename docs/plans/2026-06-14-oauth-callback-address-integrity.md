# OAuth Callback Address Integrity

## Status: In Progress

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
