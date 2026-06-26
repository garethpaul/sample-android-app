#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd -P)
TEST_ROOT=$(mktemp -d)
trap 'rm -rf "$TEST_ROOT"' EXIT HUP INT TERM

if [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/javac" ] && [ -x "$JAVA_HOME/bin/java" ]; then
  JAVAC=$JAVA_HOME/bin/javac
  JAVA=$JAVA_HOME/bin/java
elif command -v javac >/dev/null 2>&1 && command -v java >/dev/null 2>&1; then
  JAVAC=$(command -v javac)
  JAVA=$(command -v java)
else
  echo "Java compiler/runtime unavailable" >&2
  exit 1
fi

mkdir -p "$TEST_ROOT/com/example/app"
cat > "$TEST_ROOT/com/example/app/SecureImageUrlTest.java" <<'JAVA'
package com.example.app;

import java.io.IOException;

public final class SecureImageUrlTest {
    public static void main(String[] args) throws Exception {
        assertEquals("https", SecureImageUrl.parse("https://example.com/image.png").getProtocol());
        assertRejected("http://example.com/image.png");
        assertRejected("file:///tmp/image.png");
        assertRejected("not a URL");
        assertRejected(null);
        System.out.println("Secure image URL tests passed.");
    }

    private static void assertRejected(String value) throws Exception {
        try {
            SecureImageUrl.parse(value);
        } catch (IOException expected) {
            return;
        }
        throw new AssertionError("Expected URL rejection: " + value);
    }

    private static void assertEquals(String expected, String actual) {
        if (!expected.equals(actual)) {
            throw new AssertionError("Expected " + expected + ", got " + actual);
        }
    }
}
JAVA

"$JAVAC" -d "$TEST_ROOT" \
  "$ROOT_DIR/app/src/main/java/com/example/app/SecureImageUrl.java" \
  "$TEST_ROOT/com/example/app/SecureImageUrlTest.java"
"$JAVA" -cp "$TEST_ROOT" com.example.app.SecureImageUrlTest
