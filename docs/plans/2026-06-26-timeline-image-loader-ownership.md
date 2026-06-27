# Timeline Image Loader Ownership Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Keep repeated timeline refreshes from leaking one five-thread image-loader pool per successful response.

**Architecture:** HomeActivity owns one TweetAdapter for its lifetime and notifies it after revision-safe row replacement. TweetAdapter exposes teardown that shuts down its ImageLoader executor; HomeActivity performs that teardown before ad and Activity destruction.

**Tech Stack:** Legacy Java/Android AsyncTask, Ruby source contracts and hostile mutations, POSIX shell, GNU Make.

---

Status: Completed

### Task 1: Add the failing ownership contract

**Files:**
- Modify: `scripts/check_timeline_refresh.rb`
- Modify: `scripts/test-timeline-refresh-mutations.rb`

Require one activity-owned adapter, null-guarded creation, refresh notification, and teardown before `moPubView.destroy()`.

Run: `ruby scripts/check_timeline_refresh.rb`
Expected: FAIL because every successful refresh currently creates another adapter and executor.

### Task 2: Reuse and close the adapter

**Files:**
- Modify: `app/src/main/java/com/example/app/HomeActivity.java`
- Modify: `app/src/main/java/com/example/app/TweetAdapter.java`
- Modify: `app/src/main/java/com/example/app/ImageLoader.java`

Add the adapter field, create it only once, call `notifyDataSetChanged()` on later successful refreshes, and shut down the loader executor during Home teardown.

### Task 3: Update evidence and validate

**Files:**
- Modify: `AGENTS.md`
- Modify: `CHANGES.md`
- Modify: `README.md`
- Modify: `SECURITY.md`

Run: `make check`
Expected: portable Java harnesses, Ruby contracts, hostile mutations, Make authority tests, and hygiene checks pass; legacy Gradle remains skipped unless explicitly enabled with a compatible SDK.
