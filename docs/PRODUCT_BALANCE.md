# MindShift — Product & Balance Specification

## Core loop
1. Player receives one puzzle.
2. Player chooses a reasoning approach.
3. Wrong attempts teach through feedback rather than hard-locking the player.
4. Hint is available once per puzzle and reduces score.
5. Correct solutions award stars and score.
6. Explanation reinforces the reasoning pattern.
7. Next level unlocks sequentially.

## Difficulty tiers
| Tier | Name | Default time | Score multiplier |
|---|---|---:|---:|
| 1 | Boshlang‘ich | 90s | 1.00x |
| 2 | O‘rta | 75s | 1.15x |
| 3 | Murakkab | 60s | 1.35x |
| 4 | Ekspert | 50s | 1.60x |
| 5 | MindShift | 40s | 2.00x |

## Content mix target
For a 100-puzzle season:
- Pattern: 20%
- Logic: 20%
- Observation: 15%
- Sequence: 15%
- Spatial: 10%
- Assumption: 10%
- MindShift: 10%

Answer types should target approximately:
- Text: 35%
- Number: 30%
- Choice: 25%
- True/False: 10%

## Fairness rules
- Every puzzle has one intended solution or an explicitly enumerated accepted-answer set.
- Wording must not rely on hidden facts outside the prompt.
- Hints reveal a reasoning direction, not the answer directly.
- Explanations must state why the intended answer wins.
- Difficulty is based on reasoning complexity, not obscure knowledge.
- Timed puzzles must allow enough time for a careful mobile reader.
- A wrong answer should never silently advance the player.

## Daily Challenge
- Exactly 3 deterministic puzzles per calendar date.
- Daily selection is stable for the same date.
- Completing all 3 counts as one daily completion.
- Daily streak rewards should increase at 3 and 7 consecutive days.
- Missing a day resets the active streak but preserves the all-time best.

## Lives
- Maximum: 3.
- A failed/expired challenge can consume a life when the product layer enables life gating.
- Recovery: one life per 5 minutes, capped at 3.
- Never remove completed progress because lives reach zero.

## Release quality gates
Before production release:
- 100+ reviewed puzzles.
- All puzzles have explanations.
- All answer types covered by UI tests.
- Save migration tested from previous versions.
- Daily challenge deterministic test passes.
- Timeout and life recovery tests pass.
- Godot headless project parse passes.
- Android device test covers keyboard, touch, safe area, pause/resume, and back navigation.
