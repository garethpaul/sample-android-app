# Sample Android App Baseline

## Status: Completed

## Context

`sample-android-app` is a legacy Android prototype for Twitter OAuth, a home
screen, image loading, and ad-network wiring. The default maintenance gate needs
to catch repository-safety issues without requiring the old Android Gradle
stack to resolve on every workstation.

## Objectives

- Keep Twitter and ad-network credentials in a local ignored `Const.java`.
- Preserve wrapper, dependency, and generated-output repository hygiene.
- Reject hardcoded ad-unit IDs in source files.
- Keep stream-copy failures observable through narrow `IOException` handling.
- Maintain completed maintenance plans under `docs/plans`.

## Work Completed

- Confirmed `make check` runs the static Android sample contract checker.
- Added canonical `docs/plans` coverage for the current maintenance baseline.
- Extended the contract checker to require completed `docs/plans` entries with
  `make check` verification.
- Updated README, VISION, and CHANGES to make the baseline discoverable.

## Verification

- `ruby scripts/check_android_contract.rb`
- `make check`
- `make verify`
- `git diff --check`

## Follow-Up Candidates

- Run `RUN_LEGACY_GRADLE=1 make verify` on a workstation with a compatible
  legacy Android SDK.
- Add mock-auth notes before changing Twitter OAuth behavior.
