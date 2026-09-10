# Analytics Event Contract

MindShift telemetry is intentionally provider-neutral. `EventTracker` owns the stable first-party event vocabulary; gameplay code records events but does not depend on an analytics SDK.

## Events

| Event | Required payload | Optional payload | Privacy boundary |
|---|---|---|---|
| `app_started` | none | `puzzle_count` | aggregate count only |
| `level_selected` | `level` | none | numeric game state |
| `level_started` | `level`, `puzzle_id`, `difficulty`, `daily` | none | game/content identifiers only |
| `answer_submitted` | `puzzle_id`, `correct`, `attempt`, `daily` | none | outcome metadata only; never answer text |
| `level_solved` | `puzzle_id` | score/timing fields when emitted by the progression layer | game performance only |
| `level_failed` | `puzzle_id` | score/timing fields when emitted by the progression layer | game performance only |
| `hint_used` | `puzzle_id` | none | game state only |
| `progress_reset` | none | none | no user identity |

## Naming rules

- Event names are lowercase `snake_case` and must remain stable once shipped.
- Payload keys are lowercase `snake_case`.
- Payloads contain gameplay state only; no name, email, device identifier, IP address, precise location, free-form user text, or answer text is part of the contract.
- Vendor SDKs must subscribe at the `EventTracker.event_recorded` boundary rather than being imported by gameplay services.
- Event recording is best-effort and local-first; disabling the tracker must not affect gameplay.

The contract is enforced by `tests/test_analytics_event_contract.py` against `src/event_tracker.gd` and representative gameplay call sites.
