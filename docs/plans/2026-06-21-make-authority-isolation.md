# Make Authority Isolation

## Status: Completed

## Context

The protected repository root prevented `ROOT=/tmp` from redirecting checks,
but GNU Make still accepted caller-controlled `MAKEFILES`, `MAKEFILE_LIST`,
`SHELL`, `.SHELLFLAGS`, and `RUBY`. Those channels could replace the recipe
shell or turn the Android contract into a no-op; GNU Make startup inputs also
needed explicit detection and documented limits.

## Requirements

- **R1:** Load the repository Makefile alone and reject overridden file lists.
- **R2:** Derive the checkout root safely from the exact Makefile path.
- **R3:** Fix the shell, shell flags, and Ruby checker used by quality targets.
- **R4:** Keep `RUN_LEGACY_GRADLE` and `ANDROID_HOME` caller-configurable.
- **R5:** Exercise every public target across hostile authority inputs.

## Implementation

- Hardened Make authority before target recipes can run and added deferred
  validation after every Makefile has been parsed.
- Added `root-test` with an isolated checkout containing quotes, spaces, and
  command-substitution syntax in its path.
- Covered all six public targets across nine authority modes, plus explicit
  inert configuration-data, `MAKEFILES`, `MAKEFILE_LIST`, and preceding and
  trailing multiple-Makefile cases.
- Kept the legacy Android build opt-in and did not change application behavior.
- Kept Ruby discovery on the provisioned `PATH`; local callers must treat that
  path as trusted.
- Recorded the GNU Make startup boundary: a `MAKEFILES` preload is parsed before
  this Makefile can reject it, so the guard prevents repository recipes but
  cannot undo preload side effects.
- Added a literal `$()` checkout-path probe that fails closed without executing
  the apparent command substitution.

## Verification

- `make root-test` passed 54 target/authority cases, two inert
  configuration-data cases, a detected preload startup, and five rejection cases.
- The literal `$()` checkout-path case failed closed without creating its marker.
- `make check` passed from the repository and through an absolute Makefile path.
- Ruby and shell syntax checks, `git diff --check`, and repository integrity
  screening passed.
