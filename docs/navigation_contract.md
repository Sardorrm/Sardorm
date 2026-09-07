# Navigation Contract

## Required flow

`Home → Levels → Puzzle → Result → Next Level`

Supported entry points:
- Home **DAVOM ETISH** starts the current unlocked level.
- Home **DARAJALAR** opens the level browser.
- Selecting an unlocked level starts that puzzle.
- A correct answer exposes **KEYINGI DARAJA** and preserves progress through the existing save path.
- Completing the final available level returns to the level browser.

## Back behavior

- On an active puzzle, Android Back (`ui_cancel`) maps to the existing pause action.
- While paused, the session must remain paused and the timer must not advance.
- Leaving a paused puzzle returns to the level browser rather than producing a dead end.
- On non-game screens, Back returns to Home.

## State rules

- Puzzle state is owned by `GameSession` and is reset when a new puzzle is rendered.
- Level selection is persisted before entering the selected puzzle.
- Solved progress is persisted before advancing to the next level.
- A puzzle cannot accept answers while paused, finished, or outside the active session state.

## Verification status

Static code inspection confirms the intended flow and guards. Real Android Back-button behavior and visual navigation must still be verified on a physical Android device before release; that device gate remains a blocker until run on hardware.
