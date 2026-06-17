# Logout Back Stack Revocation

Status: In Progress

## Problem

`HomeActivity.logoutFromTwitter()` clears persisted OAuth state and launches
`MainActivity`, but leaves the authenticated Home activity on the task back
stack. Pressing Back can resume the existing Home instance with already-loaded
profile and timeline content after logout.

## Requirements

1. Finish `HomeActivity` after successful session clearing and login navigation.
2. Preserve the fail-closed behavior that retains the current screen when
   preference clearing fails.
3. Preserve complete-session entry validation, credential purge, callback
   correlation, one-shot request tokens, persistence gating, and sanitized logs.
4. Add mutation-sensitive static contracts, synchronized guidance, and
   truthful completed verification evidence.

## Approach

- Keep the existing synchronous clear result as the authorization boundary.
- Start `MainActivity`, then call `finish()` so the authenticated activity
  cannot be revisited through Back.
- Protect ordering and failure-branch behavior in the dependency-free Android
  source contract.

## Scope Boundaries

- Do not change OAuth endpoints, callback routing, consumer configuration,
  manifests, dependencies, vendored JARs, layouts, or Android task flags.
- Do not clear in-memory display data separately or redesign activity
  navigation beyond removing the logged-out Home instance.
- Keep this change stacked on PR #12; do not merge or close the stack without
  explicit owner authorization.

## Implementation Units

- `app/src/main/java/com/example/app/HomeActivity.java`: finish Home after
  successful logout navigation.
- `scripts/check_android_contract.rb`: enforce clear, failure return,
  navigation, and finish ordering.
- `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`: document back-stack
  revocation after logout.

## Verification Plan

- Run the focused static Android contract and complete repository/external
  `make check` gate.
- Reject mutations that remove `finish()`, move it before clear success or
  navigation, remove failure termination, weaken guidance, or falsify evidence.
- Audit exact paths, generated artifacts, credentials, dependencies, vendored
  binaries, conflicts, modes, whitespace, and upstream equality.

## Risks

- Finishing before successful clearing would hide a failed logout while leaving
  credentials persisted.
- Finishing before navigation could expose an empty task transition on legacy
  Android versions.
