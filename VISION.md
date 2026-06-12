## Sample Android App Vision

Sample Android App is a legacy Android prototype for Twitter OAuth login/signup
and MoPub monetization, with sample login and home screens.

The repository is useful as a historical Android app experiment and as a visual
reference for authentication and monetization wiring from its original era.

The goal is to preserve the sample while making clear that it is not production
architecture and that credentials, ads, and dependency age need careful review.

The current focus is:

Priority:

- Preserve the login and home-screen sample flow
- Keep Twitter and ad-network credentials out of source control
- Keep helper failures observable during static verification
- Keep local IDE metadata out of the portable sample
- Keep app backup disabled for credential-adjacent runtime state
- Keep launcher and OAuth callback exposure limited to the login entry point
- Keep activity exported state explicit in the manifest
- Keep image cache data in app-internal storage
- Keep image-load failures observable without crashing bitmap rendering
- Keep partial image cache writes from being decoded
- Keep cached image decode streams closed after bitmap reads
- Keep empty image URLs placeholder-backed without cache lookups
- Keep profile image failures observable and placeholder-backed
- Avoid optional location and shared-storage permissions in the default sample
- Maintain screenshot references for visual context
- Keep completed maintenance plans under `docs/plans`
- Keep GitHub Actions aligned with the local Ruby `make check` baseline
- Treat the Android project structure and dependencies as legacy

Next priorities:

- Add setup notes for Android SDK, OAuth keys, and ad configuration
- Document which code paths are placeholders versus working features
- Add a mock-auth mode for local demos
- Modernize Gradle and dependencies in a dedicated compatibility pass

Contribution rules:

- One PR = one focused auth, ad, UI, dependency, or documentation change.
- Do not commit OAuth secrets, ad-network keys, or user data.
- Include emulator or device notes for behavior changes.
- Keep production-readiness caveats visible.
- Keep `.github/workflows/check.yml` in sync with the local static contract.

## Security And Responsible Use

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

Auth and monetization samples can affect real users and accounts. The app
should make external services explicit and should avoid collecting profile,
session, or ad data without documented consent.

## What We Will Not Merge (For Now)

- Checked-in credentials
- Optional location or shared-storage permissions without a dedicated rationale
- Hidden analytics or ad behavior
- Production-readiness claims
- Broad Android rewrites without preserving the sample flow

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
