# HTTPS Image Transport

Status: Completed

## Context

The legacy profile and timeline image paths opened generic URLs, cast their
connections to HTTP, and consumed Twitter4J methods that can return cleartext
profile-image locations. Non-HTTP schemes could also fail with an unchecked
cast instead of the existing placeholder-backed image failure path.

## Goals

- Require HTTPS before either image loader opens a connection.
- Use the vendored Twitter4J HTTPS profile-image accessors.
- Reject malformed, null, HTTP, and non-network image URLs predictably.
- Preserve placeholder behavior, cache behavior, and lifecycle ownership.

## Work Completed

- Added the dependency-free `SecureImageUrl` policy.
- Switched profile and timeline downloads to `HttpsURLConnection`.
- Switched persisted profile and timeline image URLs to Twitter4J HTTPS methods.
- Added a Java behavior harness and mutation-sensitive repository contracts.
- Updated security, vision, maintainer, README, and changelog guidance.

## Verification Completed

- The red-first Java harness failed while `SecureImageUrl.java` was absent.
- `make lint`, `make test`, `make build`, `make verify`, and `make check`
  passed with the secure URL, timeline publication, and profile publication
  Java harnesses plus all Ruby source and mutation gates.
- Absolute-Makefile `make check` passed from an external working directory.
- Focused hostile mutations restoring HTTP acceptance, bypassing the shared
  parser, restoring generic connections, restoring cleartext-capable Twitter
  accessors, or removing plan evidence were rejected.
- Generated artifact, credential, conflict-marker, and `git diff --check`
  inspections passed.
