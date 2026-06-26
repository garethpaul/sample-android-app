# Profile Image Lifecycle Implementation Plan

## Status: Completed

### Task 1: Add publication proof

- Compile a Java 7 harness against the new revision gate.
- Prove stale and invalidated completions cannot publish.

### Task 2: Own task lifecycle

- Capture each profile-image task and its revision.
- Invalidate and cancel before logout navigation and during teardown.
- Guard UI publication with revision and cancellation state.

### Task 3: Bound transport retention

- Set finite connect and read timeouts.
- Keep the HTTP connection task-local and disconnect it in `finally`.
- Preserve placeholder rendering for current failed downloads.

### Task 4: Validate and publish

- Add source, mutation, documentation, and plan contracts.
- Run focused and full gates.
- Review, open a PR, and merge only after the final hosted head is green.

## Verification Evidence

- Pure Java RED failed because `ProfileImagePublication` did not exist; GREEN
  proves current, stale, replacement, and invalidated revisions.
- The Home source checker failed on every lifecycle and transport contract
  before implementation, then passed after task ownership was added.
- Nine isolated hostile mutations were rejected.
- `make check` passed with 54 Makefile authority cases, both Java 7 behavior
  harnesses, fourteen timeline mutations, and nine profile-image mutations.
- Hosted Check runs `28213893556` and `28213894592` passed on commit
  `4cf71aa2ea8cdba0fa59682516e10d20c5882ebf`.
- Hosted CodeQL run `28213893861` passed for Actions, Java/Kotlin, and Ruby.
- `codex review --base origin/master` was attempted but could not authenticate
  to the OpenAI API (HTTP 401); manual exact-head review found no findings.
