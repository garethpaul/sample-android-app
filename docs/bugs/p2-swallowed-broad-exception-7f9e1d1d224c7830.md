# [P2][Resolved] Handle broad exception paths instead of swallowing failures

## Status

Resolved

## Severity

P2 - correctness/reliability

## Evidence

- `app/src/main/java/com/example/app/Utils.java:21`: `catch(Exception ex){}`

## Problem

A broad exception handler drops all failures and returns control without logging, surfacing an error, or preserving diagnostic state. Callers can receive null or stale data with no explanation.

## Suggested fix

Catch the narrow exception types expected in this path, log or return a structured error, and update callers to handle the failure explicitly.

## Resolution

`Utils.CopyStream` now catches only `IOException` and writes failures to Android
error logging. The static Android contract checker rejects a broad
`catch (Exception)` in the helper and requires the stream-copy failure log call.

## Review metadata

- Repository: `garethpaul/sample-android-app`
- Reviewed commit: `3a4430dc28f34c799a7eb095c5acea1a5772caed`
- Labels: `bug`, `codex-review`, `severity:P2`
- Codex review fingerprint: `7f9e1d1d224c7830`
