# Exception Log Redaction

## Status: Completed

## Context

The archived sample no longer logs preference maps, OAuth fields, profiles, or
timelines directly. It still sends caught `TwitterException` and `IOException`
objects to Logcat and calls `printStackTrace()` during OAuth request-token
failure. Exception messages and stack frames can contain request URLs, callback
details, filesystem paths, or other user-specific diagnostic state.

## Priority

Logcat is an external diagnostic boundary. Fixed tagged failure events retain
the archive's operational signal without copying uncontrolled exception text or
stack traces into captured logs. This is a source-only privacy improvement that
does not require reviving the Android 4-era build toolchain.

## Requirements

- R1. Preserve fixed tagged failure events at every existing exception path.
- R2. Do not pass caught exception objects to Android `Log` methods.
- R3. Do not call `printStackTrace()` in application Java source.
- R4. Extend the dependency-free Android contract across every application Java
  file, deriving catch-variable names so renaming an exception cannot bypass it.
- R5. Keep comment stripping and multiline detection so inactive examples do
  not create false positives and formatted calls cannot evade the guard.
- R6. Align README, security, vision, changelog, and completed-plan guidance.
- R7. Protect throwable logging, stack traces, renamed variables, docs, and plan
  completion with focused hostile mutations.

## Scope Boundaries

- Do not change OAuth, network, image-cache, or stream-copy control flow.
- Do not remove fixed tagged operational or failure events.
- Do not introduce a new logging framework or modernize the archived SDK.
- Do not claim the obsolete Twitter, advertising, or Android dependencies are
  production safe.

## Verification Plan

- `ruby scripts/check_android_contract.rb`
- `make check` locally and from outside the repository root
- workflow YAML, manifest XML, and SVG XML parsing
- vendored JAR digest verification
- focused hostile exception-log mutations with valid Git metadata
- Java brace/syntax-oriented source checks, secret screening, and
  `git diff --check`

## Work Completed

- Replaced seven throwable-bearing `Log.e` calls with the same fixed tagged
  failure messages and removed the OAuth request-token `printStackTrace()`.
- Preserved the existing exception control flow, cache cleanup, placeholders,
  return values, and fixed operational diagnostics.
- Extended the Android checker across all application Java files to reject
  stack traces, caught throwables, caught exception messages, and generated
  stack-trace strings.
- Derived catch-variable names before matching Log calls so variable renaming
  cannot bypass the guard, while retaining comment stripping and multiline
  detection.
- Aligned README, security, vision, and changelog guidance with the exception
  detail logging boundary.

## Verification

- `ruby scripts/check_android_contract.rb` passed after implementation.
- `make check` and root-independent `make -f /path/to/Makefile check` passed;
  both reported the documented legacy Gradle build skip because Android SDK 19
  is unavailable.
- Twelve focused hostile mutations were rejected: direct stack traces, direct,
  renamed, multi-catch, cast, fully qualified, dynamic-message,
  generated-stack-string, and multiline exception logging, removed fixed
  failure diagnostics, missing README guidance, and incomplete-plan status. A
  commented stack-trace control remained accepted.
- Workflow YAML, manifest XML, and both README SVG files parsed successfully.
- All four vendored SDK JARs matched `app/libs/SHA256SUMS`.
- Java delimiter checks, active exception-log scanning, high-confidence secret
  screening, and `git diff --check` passed.
- Binary, emulator, and device validation remain unavailable without the
  compatible historical Android SDK and Gradle environment.
