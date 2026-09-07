# Android Runtime QA Contract

MindShift is Android-first. This contract defines the runtime checks required before marking runtime QA complete.

## Acceptance criteria

- **Portrait:** launch and gameplay remain portrait at 720x1280 viewport configuration; no unintended rotation/layout collapse.
- **Touch:** primary controls are reachable and respond to touch; answer submission and navigation buttons do not require keyboard/focus tricks.
- **Safe area:** content remains visible and usable around Android system bars/notches; no critical controls are clipped.
- **Loading:** puzzle data loads before gameplay; missing/invalid puzzle data produces a visible error path instead of a broken gameplay screen.
- **Pause/resume:** Android back (`ui_cancel`) pauses an active puzzle; timer stops while paused and resumes without counting paused time.
- **Navigation:** back from non-game screens returns to the home screen; active puzzle navigation must preserve a deterministic state.
- **Save/restart:** progress/settings are saved through the existing save manager and can be restored after a restart.

## Verification rule

Device-only checks must be performed on a real Android device before they are marked passed. If a connected tool cannot execute an Android build/install/run, record the device verification as a blocker rather than claiming it passed.
