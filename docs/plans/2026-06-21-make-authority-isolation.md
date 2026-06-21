# Make Authority Isolation

## Status: Completed

## Context

The protected repository root prevented `ROOT=/tmp` from redirecting checks,
but GNU Make still accepted caller-controlled `MAKEFILES`, `MAKEFILE_LIST`,
`SHELL`, `.SHELLFLAGS`, and `RUBY`. Those channels could preload arbitrary Make
logic, replace the recipe shell, or turn the Android contract into a no-op.

## Requirements

- **R1:** Load the repository Makefile alone and reject overridden file lists.
- **R2:** Derive the checkout root safely from the exact Makefile path.
- **R3:** Fix the shell, shell flags, and Ruby checker used by quality targets.
- **R4:** Keep `RUN_LEGACY_GRADLE` and `ANDROID_HOME` caller-configurable.
- **R5:** Exercise every public target across hostile authority inputs.

## Implementation

- Hardened Make authority before any target definitions are evaluated.
- Added `root-test` with an isolated checkout containing quotes, spaces, and
  command-substitution syntax in its path.
- Covered all six public targets across nine authority modes, plus explicit
  inert configuration-data, `MAKEFILES`, `MAKEFILE_LIST`, and multiple-Makefile
  cases.
- Kept the legacy Android build opt-in and did not change application behavior.

## Verification

- `make root-test` passed 54 target/authority cases, two inert
  configuration-data cases, and four rejection cases.
- `make check` passed from the repository and through an absolute Makefile path.
- Ruby and shell syntax checks, `git diff --check`, and repository integrity
  screening passed.
