# MindShift Privacy & Data Review

## Scope

This review covers the current MindShift codebase, including gameplay telemetry, persistence, and release-facing documentation.

## Current data boundary

- `EventTracker` records only gameplay telemetry defined by the first-party event contract.
- The current contract excludes names, email addresses, device identifiers, IP addresses, precise location, free-form user text, and answer text.
- Gameplay events are kept in an in-memory history and emitted through `event_recorded`; the tracker does not make network requests or persist telemetry itself.
- `SaveManager` is local gameplay persistence. Its data is not an analytics identity store.
- No analytics SDK, HTTP client, webhook, or hard-coded analytics endpoint is part of the gameplay telemetry path.

## Release decision

**Current implementation: privacy-safe by default for offline gameplay.** No third-party analytics provider is enabled in the repository today, so there is no provider-specific consent or data-transfer flow to claim as implemented.

If a provider is added later, it must subscribe at the `EventTracker.event_recorded` boundary and must document data categories, purpose, retention, processor/provider, consent/opt-out behavior where required, and deletion/access handling before release.

## Release checklist

- [x] Telemetry vocabulary is explicit and provider-neutral.
- [x] Sensitive/personal fields are excluded from the event contract.
- [x] Tracker has no direct network dependency.
- [x] Tracker does not persist telemetry outside its in-memory queue.
- [x] Automated privacy-boundary regression tests exist.
- [ ] Publish a privacy-policy URL if analytics or online services are enabled before launch.
- [ ] Re-review this document if external analytics, ads, accounts, cloud saves, or other data collection is introduced.

## Verification boundary

Automated tests can verify repository-level privacy constraints. They cannot establish legal compliance for a particular jurisdiction or verify a future third-party provider's actual data handling. Those remain release/compliance review responsibilities.
