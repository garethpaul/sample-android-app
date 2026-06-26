# Profile Image Lifecycle Design

## Status: Completed

## Problem

`HomeActivity.GetXMLTask` retains the Activity while downloading a profile
image and always publishes into its `ImageView` from `onPostExecute`. Successful
logout and `onDestroy()` invalidate timeline work but do not invalidate or
cancel this second asynchronous publication path. The HTTP connection also has
no connect/read timeout and is not disconnected after successful reads.

Android's official [`AsyncTask` reference](https://developer.android.com/reference/android/os/AsyncTask)
requires lifecycle-aware cancellation and notes that cancelled work must check
its cancellation state. Cancellation alone is insufficient here because a
completion can race teardown and blocking I/O may not stop immediately.

## Options

1. **Revision gate, cancellation, and bounded connection ownership.**
   Recommended. Give each task a revision, invalidate and cancel during logout
   and teardown, reject stale UI publication, use finite connect/read timeouts,
  and always disconnect the task-owned HTTP connection, including connect and
  response failures after ownership is established.
2. Cancellation only. Rejected because completion can race cancellation and
   network I/O can retain the Activity until it returns.
3. Check `isFinishing()` in `onPostExecute`. Rejected because it does not model
   task ownership, does not cover all teardown states, and leaves transport
   retention unbounded.

## Decision

Add a small Java 7 `ProfileImagePublication` revision gate, keep the active
`GetXMLTask` in a field, invalidate and cancel it before logout navigation and
in `onDestroy()`, and require the captured revision before touching the image
view. Move connection ownership into the task, set 30-second connect/read
timeouts, and disconnect in `finally` after closing the stream.

## Validation

- Pure Java RED/GREEN tests for stale, current, and invalidated publication.
- Source contracts for logout/teardown ordering, cancellation checks, timeout,
  and disconnect behavior.
- Hostile mutations, full repository verification, hosted checks, and CodeQL.
- The repository-level acceptance command is `make check`.
