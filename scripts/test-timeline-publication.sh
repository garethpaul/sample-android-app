#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd -P)
TEST_ROOT=${TMPDIR:-/tmp}/sample-android-app-timeline-publication.$$
trap 'rm -rf "$TEST_ROOT"' EXIT HUP INT TERM

if [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/javac" ] && [ -x "$JAVA_HOME/bin/java" ]; then
  JAVAC=$JAVA_HOME/bin/javac
  JAVA=$JAVA_HOME/bin/java
elif command -v javac >/dev/null 2>&1 && command -v java >/dev/null 2>&1; then
  JAVAC=$(command -v javac)
  JAVA=$(command -v java)
else
  printf '%s\n' 'timeline publication tests require a JDK' >&2
  exit 1
fi

mkdir -p "$TEST_ROOT/classes" "$TEST_ROOT/com/example/app"

cat > "$TEST_ROOT/com/example/app/TimelinePublicationTest.java" <<'JAVA'
package com.example.app;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public final class TimelinePublicationTest {
    public static void main(String[] args) {
        testSerialSuccessFailureAndEmpty();
        testParallelStaleSuccessThenCurrentSuccess();
        testParallelStaleSuccessThenCurrentFailure();
        testParallelStaleFailureThenCurrentSuccess();
        testParallelStaleFailureThenCurrentFailure();
        testParallelCurrentSuccessThenStaleFailure();
        testInvalidatedCompletionIsStale();

        System.out.println("Timeline publication tests passed");
    }

    private static void testSerialSuccessFailureAndEmpty() {
        CompletionHarness harness = new CompletionHarness();

        long success = harness.begin();
        harness.complete(success, true, rows("tweet-a", "tweet-b"));
        harness.assertState(false, 1, "tweet-a", "tweet-b");

        long failure = harness.begin();
        harness.complete(failure, false, rows("partial"));
        harness.assertState(false, 1, "tweet-a", "tweet-b");

        long empty = harness.begin();
        harness.complete(empty, true, rows());
        harness.assertState(false, 2);
    }

    private static void testParallelStaleSuccessThenCurrentSuccess() {
        CompletionHarness harness = new CompletionHarness("existing");
        long stale = harness.begin();
        long current = harness.begin();

        harness.complete(stale, true, rows("stale"));
        harness.assertState(true, 0, "existing");

        ArrayList<String> currentRows = rows("current");
        harness.complete(current, true, currentRows);
        currentRows.add("late mutation");
        harness.assertState(false, 1, "current");
    }

    private static void testParallelStaleFailureThenCurrentFailure() {
        CompletionHarness harness = new CompletionHarness("existing");
        long stale = harness.begin();
        long current = harness.begin();

        harness.complete(stale, false, rows("partial"));
        harness.assertState(true, 0, "existing");

        harness.complete(current, false, rows("partial"));
        harness.assertState(false, 0, "existing");
    }

    private static void testParallelStaleSuccessThenCurrentFailure() {
        CompletionHarness harness = new CompletionHarness("existing");
        long stale = harness.begin();
        long current = harness.begin();

        harness.complete(stale, true, rows("stale"));
        harness.assertState(true, 0, "existing");

        harness.complete(current, false, rows("partial"));
        harness.assertState(false, 0, "existing");
    }

    private static void testParallelStaleFailureThenCurrentSuccess() {
        CompletionHarness harness = new CompletionHarness("existing");
        long stale = harness.begin();
        long current = harness.begin();

        harness.complete(stale, false, rows("partial"));
        harness.assertState(true, 0, "existing");

        harness.complete(current, true, rows("current"));
        harness.assertState(false, 1, "current");
    }

    private static void testParallelCurrentSuccessThenStaleFailure() {
        CompletionHarness harness = new CompletionHarness("existing");
        long stale = harness.begin();
        long current = harness.begin();

        harness.complete(current, true, rows("newest"));
        harness.assertState(false, 1, "newest");

        harness.complete(stale, false, rows("partial"));
        harness.assertState(false, 1, "newest");
    }

    private static void testInvalidatedCompletionIsStale() {
        CompletionHarness harness = new CompletionHarness("existing");
        long pending = harness.begin();

        harness.invalidate();
        harness.complete(pending, true, rows("stale"));

        harness.assertState(true, 0, "existing");
    }

    private static final class CompletionHarness {
        private final ArrayList<String> displayed = new ArrayList<String>();
        private final TimelinePublication<String> publication =
                new TimelinePublication<String>(displayed);
        private boolean loading;
        private int adapterChanges;

        CompletionHarness(String... initialRows) {
            displayed.addAll(Arrays.asList(initialRows));
        }

        long begin() {
            loading = true;
            return publication.begin();
        }

        void invalidate() {
            publication.invalidate();
        }

        void complete(long revision, boolean successful, ArrayList<String> rows) {
            if (!publication.publish(revision, successful, rows)) {
                return;
            }

            loading = false;
            if (successful) {
                adapterChanges += 1;
            }
        }

        void assertState(boolean expectedLoading, int expectedAdapterChanges,
                String... expectedRows) {
            if (loading != expectedLoading) {
                throw new AssertionError("expected loading=" + expectedLoading
                        + " but was " + loading);
            }
            if (adapterChanges != expectedAdapterChanges) {
                throw new AssertionError("expected adapter changes=" + expectedAdapterChanges
                        + " but was " + adapterChanges);
            }
            assertRows(displayed, expectedRows);
        }
    }

    private static ArrayList<String> rows(String... values) {
        return new ArrayList<String>(Arrays.asList(values));
    }

    private static void assertRows(List<String> actual, String... expected) {
        List<String> expectedRows = Arrays.asList(expected);
        if (!actual.equals(expectedRows)) {
            throw new AssertionError("expected " + expectedRows + " but was " + actual);
        }
    }

}
JAVA

"$JAVAC" -source 7 -target 7 -d "$TEST_ROOT/classes" \
  "$ROOT_DIR/app/src/main/java/com/example/app/TimelinePublication.java" \
  "$TEST_ROOT/com/example/app/TimelinePublicationTest.java"
"$JAVA" -cp "$TEST_ROOT/classes" com.example.app.TimelinePublicationTest
