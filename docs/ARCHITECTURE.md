# MindShift Architecture

## Goal
Keep gameplay rules independent from presentation so the visual layer can be redesigned without rewriting progression, saves, puzzle logic, or analytics.

## Layers

### 1. Content / Domain
- `PuzzleDefinition` — typed, immutable-in-practice representation of a puzzle definition.
- `PuzzleRepository` — the only runtime boundary for loading and querying puzzle content.
- `PuzzleEngine` — answer matching and compatibility with the current JSON format.

### 2. Gameplay State
- `GameSession` — one puzzle attempt: active/solved/failed state, attempts, hints, timing, last answer.
- `LevelManager` — unlock and completion rules.
- `StatsManager` — aggregate player performance and thinking-profile score.

### 3. Persistence
- `SaveManager` — versioned local save contract.
- Save data must remain backward-compatible when fields are added.
- Never store derived UI state as the source of truth.

### 4. Presentation
- `main.gd` currently hosts the prototype presentation layer.
- Future screens should consume state from gameplay/domain services rather than implementing rules themselves.
- Recommended future scene boundaries: `Boot`, `MainMenu`, `LevelSelect`, `Puzzle`, `Result`, `Stats`, `Settings`.

### 5. Telemetry boundary
- `EventTracker` defines stable first-party event names and payloads.
- No analytics vendor SDK is embedded in gameplay code.
- A provider can subscribe later without changing puzzle/progression logic.

## Puzzle contract

Required fields:
- `id`: stable unique identifier; never reuse an ID for different content.
- `category`: gameplay category.
- `difficulty`: integer 1–5.
- `prompt`: player-facing question.
- `answer`: canonical answer.
- `hint`: reasoning-oriented hint.

Optional fields:
- `answers`: accepted alternatives.
- `answer_type`: `text` or `number`.
- `time_limit_seconds`: positive value enables a timed challenge.
- `tags`: content/analytics tags.

## Progression rules

1. Level 1 is always unlocked.
2. Completing level N unlocks N+1.
3. Selecting an unlocked level changes the active level but does not mark it complete.
4. Completion is stored by stable level index/ID contract.
5. Reset is explicit and destructive.

## Session lifecycle

`IDLE → ACTIVE → SOLVED`

Incorrect submissions temporarily enter `FAILED` for event/feedback semantics and immediately return to `ACTIVE`, so a failed attempt never blocks retrying.

## Difficulty design

- 1: one rule, low cognitive load.
- 2: one rule plus observation or wording trap.
- 3: combined reasoning or multi-step inference.
- 4: competing hypotheses, time pressure, or non-obvious transformation.
- 5: expert MindShift challenge requiring a strategy change.

Difficulty is a content contract, not a cosmetic label.

## Production readiness gates

Before release:
- puzzle schema tests pass;
- all puzzle IDs are unique and stable;
- every answer has a deterministic matching policy;
- no known ambiguous puzzle remains;
- save migration is tested;
- progression cannot skip locked content;
- analytics events contain no unnecessary personal data;
- Android touch/performance testing passes;
- release build is generated and installed on a real device.
