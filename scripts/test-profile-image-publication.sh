#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd -P)
TEST_ROOT=${TMPDIR:-/tmp}/sample-android-app-profile-image-publication.$$
trap 'rm -rf "$TEST_ROOT"' EXIT HUP INT TERM

if [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/javac" ] && [ -x "$JAVA_HOME/bin/java" ]; then
  JAVAC=$JAVA_HOME/bin/javac
  JAVA=$JAVA_HOME/bin/java
elif command -v javac >/dev/null 2>&1 && command -v java >/dev/null 2>&1; then
  JAVAC=$(command -v javac)
  JAVA=$(command -v java)
else
  printf '%s\n' 'profile image publication tests require a JDK' >&2
  exit 1
fi

mkdir -p "$TEST_ROOT/classes" "$TEST_ROOT/com/example/app"

cat > "$TEST_ROOT/com/example/app/ProfileImagePublicationTest.java" <<'JAVA'
package com.example.app;

public final class ProfileImagePublicationTest {
    public static void main(String[] args) {
        ProfileImagePublication publication = new ProfileImagePublication();

        long stale = publication.begin();
        long current = publication.begin();
        assertFalse(publication.canPublish(stale), "older revision must be stale");
        assertTrue(publication.canPublish(current), "current revision must publish");

        publication.invalidate();
        assertFalse(publication.canPublish(current), "invalidated revision must be stale");

        long replacement = publication.begin();
        assertTrue(publication.canPublish(replacement), "new revision must publish");

        System.out.println("Profile image publication tests passed");
    }

    private static void assertTrue(boolean value, String message) {
        if (!value) {
            throw new AssertionError(message);
        }
    }

    private static void assertFalse(boolean value, String message) {
        assertTrue(!value, message);
    }
}
JAVA

"$JAVAC" -source 7 -target 7 -d "$TEST_ROOT/classes" \
  "$ROOT_DIR/app/src/main/java/com/example/app/ProfileImagePublication.java" \
  "$TEST_ROOT/com/example/app/ProfileImagePublicationTest.java"
"$JAVA" -cp "$TEST_ROOT/classes" com.example.app.ProfileImagePublicationTest
