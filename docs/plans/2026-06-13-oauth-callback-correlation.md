# OAuth Callback Correlation

## Status: Planned

## Context

`MainActivity` recognizes OAuth callbacks with a string prefix and exchanges
the in-memory request token using only the callback verifier. It does not
require the callback's `oauth_token` to match the request token that initiated
the authorization flow, and prefix matching can accept callback origins beyond
the configured scheme and host.

OAuth 1.0a returns the authorized request token and verifier in the callback,
and the access-token exchange uses that same request token. The archived sample
should correlate those values before exchanging credentials.

## Priority

The login activity is exported for a browsable callback. Rejecting mismatched,
incomplete, or wrongly addressed callbacks before network exchange reduces
login CSRF/session-swapping risk without changing stored access-token behavior.

## Objectives

- Match the callback's parsed scheme and host exactly.
- Require a live request token before callback exchange.
- Require the callback `oauth_token` to equal the active request token.
- Require a nonempty `oauth_verifier`.
- Reject invalid callbacks with fixed, non-sensitive logging.
- Add mutation-sensitive static contracts compatible with the archival build.

## Implementation Units

### U1. Define callback validation contract

**Goal:** Centralize the exact origin and request-token correlation decision.

**Files:** `app/src/main/java/com/example/app/MainActivity.java`

**Approach:** Add a small package-visible helper over `Uri` and `RequestToken`
that validates scheme, host, token, and verifier before returning success.

**Test scenarios:** Static contract mutations cover null request state, scheme
or host prefix acceptance, missing token/verifier, and token mismatch.

**Verification:** The helper is side-effect free and returns false for every
incomplete or mismatched callback shape.

### U2. Gate token exchange on correlation

**Goal:** Prevent access-token exchange until callback validation succeeds.

**Dependencies:** U1

**Files:** `app/src/main/java/com/example/app/MainActivity.java`,
`scripts/check_android_contract.rb`

**Approach:** Replace callback string-prefix dispatch with the helper, retrieve
the verifier only after validation, and use a fixed rejection log that contains
no callback token, verifier, URI, or exception details.

**Verification:** The Android contract rejects validation bypass, direct
exchange before validation, dynamic callback logging, and weakened origin or
token comparisons.

### U3. Synchronize security evidence

**Goal:** Keep repository guidance and the completed plan aligned with callback
correlation.

**Dependencies:** U1, U2

**Files:** `README.md`, `VISION.md`, `SECURITY.md`, `CHANGES.md`,
`docs/plans/2026-06-13-oauth-callback-correlation.md`

**Approach:** Document the exact-origin and request-token match requirement,
the static-only validation boundary, and actual verification evidence.

**Verification:** Focused hostile mutations and `make check` pass with only the
documented legacy Gradle skip.

## Scope Boundary

This change does not persist request tokens across process death, migrate from
OAuth 1.0a, update the archived Twitter SDK, or claim emulator/device coverage.

## References

- OAuth Core 1.0 Revision A, sections 6.2.3 and 6.3.1:
  https://oauth.net/core/1.0a/
- X access-token exchange documentation:
  https://developer.x.com/ja/docs/basics/authentication/api-reference/access_token
