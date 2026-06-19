# Sensitive Log Redaction

## Status: Completed

## Context

The legacy Twitter sample writes complete preference maps and user-derived
profile and timeline values to Android Logcat. The preference maps contain the
stored OAuth token and token secret, so routine app startup can disclose
credentials to log readers and captured diagnostics.

## Priority

Credential and user-content logging is a direct privacy defect that can be
removed and verified without reviving the obsolete Android build toolchain.

## Requirements

- R1. Remove active logging of complete `SharedPreferences` maps.
- R2. Remove active logging of user names, profile image URLs, timelines, and
  rendered tweet collections.
- R3. Preserve event and failure logging that does not include sensitive state.
- R4. Make the dependency-free Android contract reject sensitive Logcat calls,
  including multiline calls, uncommented legacy examples, and dynamic login
  exception messages.
- R5. Document the logging boundary in project security and maintenance notes.
- R6. Verify the contract with focused hostile mutations and `make check`.

## Scope Boundaries

- Do not redesign OAuth storage or authentication behavior.
- Do not suppress tagged operational or exception logging.
- Do not claim the obsolete Twitter or advertising integrations are production
  safe.

## Verification Plan

- `ruby scripts/check_android_contract.rb`
- `make check`
- focused sensitive-log mutations
- `git diff --check`

## Work Completed

- Removed preference-map, profile-value, timeline, and rendered-tweet logging
  from the login and home activities.
- Replaced dynamic Twitter login exception text with a fixed tagged failure
  event while retaining operational and failure observability.
- Added a comment-aware, multiline static contract for sensitive Logcat calls
  and aligned README, security, vision, and changelog guidance.

## Verification

- `ruby scripts/check_android_contract.rb` passed.
- `make check` passed with the legacy Gradle build skipped by documented policy.
- 10 focused hostile mutations were rejected with valid Git metadata.
- `git diff --check` passed.
