# Android Sample Contract

## Problem

The repository mixed local build artifacts, non-copyable credential examples,
and a hardcoded MoPub ad unit into the sample source. The Gradle wrapper was not
executable and still used an HTTP distribution URL.

## TDD Evidence

1. Added `scripts/check_android_contract.rb` and wired it to `make lint`.
2. Ran the checker before fixes and confirmed it failed on the wrapper mode,
   HTTP wrapper URL, tracked `build/` outputs, missing ignore patterns, missing
   `Const.java.example`, and hardcoded `setAdUnitId`.
3. Fixed the repository contract and reran the verification gate.

## Verification

- `make lint`
- `make test`
- `make build`
- `make verify`
- `git diff --check`

The default build target is static because this is a legacy Android project.
Set `RUN_LEGACY_GRADLE=1` on a workstation with a compatible Android SDK to
attempt `./gradlew assembleDebug`.

After the wrapper and repository fixes, the opt-in build reached Android
resource processing in this environment but stopped because the local
`aapt` binary from build-tools 19.1.0 could not load `libz.so.1`.
