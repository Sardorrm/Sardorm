# Achievement presentation contract

## Goal
Present achievement progress consistently from the existing `AchievementManager` state.

## Acceptance criteria
- The Home screen exposes a YUTUQLAR entry point.
- The achievements screen shows unlocked count against the complete catalog.
- Every achievement definition is rendered with a locked (`🔒`) or unlocked (`✓`) marker.
- Newly unlocked achievements are surfaced after a successful puzzle or daily challenge.
- Achievement state is loaded from and persisted through the existing save/progression flow.
- No achievement is shown as unlocked unless its ID is present in `AchievementManager.unlocked`.

## Current implementation audit
`src/main.gd` already implements the presentation contract: `_show_home()` exposes YUTUQLAR, `_show_achievements()` renders the catalog and unlocked count, and successful progression appends a "Yangi yutuq" notice. `AchievementManager` remains the source of truth for unlock state.

## Verification limitation
Static code/tests can verify the contract, but real Android visual/layout verification still requires a physical Android run. This must remain a release QA blocker until performed.
