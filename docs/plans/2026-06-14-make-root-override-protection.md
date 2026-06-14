# Make Root Override Protection

## Status: Completed

## Context

The Makefile derives its repository root from the loaded file and uses that
path for static Android validation and optional legacy Gradle execution. GNU
Make command-line variables outrank an ordinary assignment, so `make ROOT=/tmp
check` can redirect those gates away from the checkout.

## Requirements

- **R1:** Prevent command-line and environment values from replacing the
  Makefile-derived repository root.
- **R2:** Keep `RUBY`, `RUN_LEGACY_GRADLE`, and `ANDROID_HOME` configurable.
- **R3:** Require the exact protected declaration in the Android checker.
- **R4:** Prove every public Make alias from the checkout and an external
  directory with a hostile `ROOT` argument.
- **R5:** Preserve credential handling, OAuth correlation, vendored-JAR
  integrity, hosted policy, and opt-in legacy Gradle behavior.

## Implementation Units

### U1. Protected Root

Give the repository-derived root override precedence without changing recipes,
runtime selection, or the legacy Gradle opt-in.

### U2. Android Contract

Extend `scripts/check_android_contract.rb` to reject weakened, duplicate,
displaced, or caller-controlled root declarations and incomplete evidence.

### U3. Verification

Run the static contract, all Make aliases, external hostile execution, Ruby
3.3 validation, mutations, and integrity screening.

## Scope Boundary

- Do not modify app source, resources, manifests, vendored JARs, or Gradle.
- Do not change OAuth, logging, preference, or callback behavior.
- Do not add credentials, build outputs, caches, or dependency changes.

## Verification

- `ruby scripts/check_android_contract.rb`
- `make check`
- external `make ROOT=/tmp check`
- root-declaration, checker, plan-status, README-index, and evidence mutations
- Ruby syntax, workflow YAML, protected-file, secret, artifact, and
  `git diff --check` gates

## Work Completed

- Protected the Makefile-derived repository root from command-line and
  environment overrides while preserving configurable Ruby and Gradle inputs.
- Added exact declaration, completed-evidence, and README-index contracts.
- Preserved all application, OAuth, manifest, vendored-SDK, and workflow
  behavior boundaries.

## Verification Results

- `ruby scripts/check_android_contract.rb` passed.
- From both the checkout and an external directory, all five public Make aliases passed.
- `make ROOT=/tmp check` passed externally while still executing the
  repository-owned Android contract.
- Ruby 3.3 passed the full static gate; legacy Gradle remained explicitly
  skipped because `RUN_LEGACY_GRADLE` was not enabled with a compatible SDK.
- Six hostile mutations were rejected across root declaration, checker
  expectation, plan status, README indexing, and recorded evidence.
- Ruby syntax, workflow YAML, exact-base protected-file comparison, secret
  screening, generated-artifact screening, and `git diff --check` passed before
  shipping.
