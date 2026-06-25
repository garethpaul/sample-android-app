# Home Timeline Lifecycle

Status: Completed

## Problem

Each timeline task owned a revision, but the revision remained current after a
successful logout or Home Activity destruction. A late callback could therefore
publish account rows and touch the finishing Activity. Home also initialized a
MoPub view without a matching teardown hook.

## Change

Add explicit timeline publication invalidation. Successful logout invalidates
before login navigation, and `onDestroy()` invalidates again before destroying
the initialized ad view and delegating to the Activity superclass.

## Verification

- RED reproduced as a Java compile failure for the missing `invalidate()` API.
- Added Java 7 coverage proving invalidated completions cannot replace rows.
- Added source contracts for logout order, teardown order, and null-safe ad cleanup.
- Four new hostile mutations remove or weaken each lifecycle boundary.
- The Java harness, source checker, mutation suite, and `make check` passed.
- No emulator or device flow was executed locally.
