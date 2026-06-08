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
- Maintain screenshot references for visual context
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

## Security And Responsible Use

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

Auth and monetization samples can affect real users and accounts. The app
should make external services explicit and should avoid collecting profile,
session, or ad data without documented consent.

## What We Will Not Merge (For Now)

- Checked-in credentials
- Hidden analytics or ad behavior
- Production-readiness claims
- Broad Android rewrites without preserving the sample flow

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
