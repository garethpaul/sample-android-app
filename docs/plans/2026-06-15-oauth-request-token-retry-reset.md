# Reset OAuth Request Tokens Before Retry

## Status: Completed

## Context

`loginToTwitter()` assigns the static `requestToken` only when
`getOAuthRequestToken()` succeeds. If an earlier authorization attempt left a
request token in memory and a later request fails, the stale token remains
eligible for callback correlation. A failed retry must not preserve OAuth
state from an older attempt.

## Requirements

- Clear any existing in-memory request token before requesting a new OAuth
  token.
- Keep a newly acquired token local until the request succeeds, then publish
  that exact token for callback correlation and browser navigation.
- Leave `requestToken` null when token acquisition fails.
- Preserve exact callback address, request-token, verifier, and one-time token
  consumption checks.
- Preserve credential storage, logout purging, fixed redacted logs, and the
  legacy Android compatibility boundary.
- Add mutation-sensitive static coverage for reset order, local token use, and
  failed-retry state.

## Implementation Units

### OAuth Retry Boundary

File: `app/src/main/java/com/example/app/MainActivity.java`

- Reset the shared callback token before starting a new request.
- Acquire the replacement into a local value and use that value for the
  authentication URL.
- Publish the replacement only after successful acquisition.

### Contract Validation

File: `scripts/check_android_contract.rb`

- Require reset-before-request ordering and local-token navigation.
- Reject direct field assignment that can preserve stale state on failure.
- Protect the focused source contract and completed plan evidence.

### Documentation

Files: `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`

- Document fail-closed request-token retries without changing the archive
  support posture.

## Verification

- focused Android source-contract validation
- repository and external-directory `make check`
- hostile reset-order, direct-assignment, navigation-token, documentation, and
  completed-plan mutations
- exact diff, generated-artifact, conflict-marker, and credential-pattern
  audits

## Scope Boundaries

- Do not change OAuth endpoints, callback address, consumer credentials,
  preference names, manifest exposure, or vendored SDK binaries.
- Do not claim Gradle, emulator, or device coverage without a compatible
  historical Android SDK.
- Do not merge or close stacked pull requests without explicit authorization.

## Work Completed

- Reset the shared request token before each new OAuth token request.
- Acquire the replacement into a local value, publish only the successful
  result, and use that same local token for browser navigation.
- Added method-local static ordering checks plus synchronized README, security,
  vision, and change-history documentation.

## Verification Results

- The focused Android source-contract validation passed.
- The repository and external-directory `make check` passed; the archival
  Gradle build remained on its explicit documented skip path because no
  compatible Android SDK was configured.
- Six hostile retry-reset mutations were rejected across reset presence and
  order, direct shared-field acquisition, navigation token selection,
  documentation, and completed-plan evidence.
- Final generated-artifact and credential-pattern audits passed alongside the
  exact-diff, conflict-marker, XML, SVG, and vendored-JAR checks.
