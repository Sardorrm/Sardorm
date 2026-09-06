# MindShift Android Release Verification

## Current runtime configuration

- Portrait-first viewport: 720×1280
- Preview override: 360×640
- Stretch mode: canvas items
- Mobile renderer: GL Compatibility
- Custom mobile theme enabled

## Device verification checklist

1. Launch the game from a clean install.
2. Confirm the main menu fits without clipping on a narrow Android screen.
3. Start campaign levels across all four answer modes.
4. Verify timer warning and critical states.
5. Pause a puzzle, wait, resume, and confirm the remaining time does not decrease while paused.
6. Submit a correct answer and verify stars, score, elapsed time, and explanation.
7. Submit an incorrect answer and verify life consumption and save behavior.
8. Complete a Daily Challenge sequence and verify streak persistence.
9. Force-close and relaunch after progress, then verify save/load.
10. Test system back navigation and keyboard behavior on text-answer puzzles.
11. Check safe areas/notches and accessibility at the smallest supported display.
12. Run a release build and verify startup, memory use, and input latency.

## Release blockers

- Runtime/device test has not yet been performed from this repository environment.
- Android signing/package ID/versioning must be configured for the actual release account.
- Store assets and privacy-policy requirements must be completed before publication.
