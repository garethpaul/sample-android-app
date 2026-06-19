# Consume OAuth Request Tokens Once

## Status: Completed

## Context

The callback gate correlates the exact address, request token, and verifier, but
the accepted static `requestToken` remains available after token exchange or a
failed callback attempt. Clearing login preferences can therefore leave an old
in-memory request token eligible for replay.

## Requirements

- Copy the validated request token into a local callback value and clear the
  static field before access-token exchange.
- Use only the consumed local value for exchange.
- Reject subsequent callbacks until a fresh login flow creates a new request
  token.
- Preserve exact callback address/token/verifier validation, fixed rejection
  logging, credential storage, and logout preference clearing.
- Add fail-closed static and mutation-sensitive coverage.

## Verification

- focused Android source-contract validation
- repository and external-directory `make check`
- hostile consume-order, exchange-argument, replay, test, documentation, and
  completed-plan mutations
- exact diff, generated-artifact, and credential-pattern audits

## Scope Boundaries

- Do not change OAuth endpoints, callback address, consumer credentials,
  preference names, manifest exposure, or legacy SDK requirements.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification Results

- The focused Android source-contract validation passed.
- The repository and external-directory `make check` passed; the archival
  Gradle build remained on its explicit documented skip path because no
  compatible Android SDK was configured.
- Five hostile request-token mutations were rejected across token copying,
  clearing, exchange argument, documentation, and completed-plan evidence.
- Final exact-diff, generated-artifact, conflict-marker, and credential-pattern
  audits found only intended paths and no secrets.
