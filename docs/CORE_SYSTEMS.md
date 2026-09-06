# MindShift — Core Systems

## Gameplay loop
1. Player selects an unlocked level.
2. `GameSession` starts a deterministic attempt.
3. Player may request one hint.
4. Answer is validated by `PuzzleEngine`.
5. Success produces score, stars, progression and achievement events.
6. Failure records the attempt and resets the achievement streak.
7. Progress is persisted through the versioned save layer.

## Separation of concerns
- `PuzzleEngine`: puzzle data loading and answer validation.
- `LevelManager`: unlock/completion/current-level state.
- `GameSession`: transient attempt state; no persistence responsibilities.
- `GameRules`: score, stars and shared gameplay rules.
- `StatsManager`: player statistics and thinking-profile calculation.
- `AchievementManager`: milestone progression.
- `SaveManager`: versioned local persistence and migration.
- `EventTracker`: analytics-ready event contract without a provider dependency.
- UI (`main.gd`): presentation and input only; game rules should not be duplicated here.

## Puzzle contract
Each puzzle requires:
- stable unique `id`
- `category`
- integer `difficulty` from 1–5
- unambiguous `prompt`
- `answer` or non-empty `answers`
- actionable `hint`

Optional future fields:
- `type`
- `explanation`
- `time_limit_seconds`
- `tags`
- `media`

## Progression design
Unlocking is sequential for the MVP. Completion is permanent. The save format is versioned so future branches, daily challenges, difficulty tracks and cloud sync can be introduced without breaking existing saves.

## Product rules
- No pay-to-win mechanics.
- Hints help reasoning rather than revealing the answer.
- Every puzzle must have a deterministic expected result.
- Touch targets must remain comfortable on small Android screens.
- The game must remain playable offline for the core campaign.
