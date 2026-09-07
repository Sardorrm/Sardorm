# MindShift — Hourly Execution Scope

The 66-hour roadmap is executed as grouped work packages. An hour is not considered complete after one small change: the implementation, related tests, regression checks, documentation, and coherent commit for that hour are handled together where safely possible.

## Execution rule

For each hour:
1. Inspect the existing implementation before changing it.
2. Complete all related sub-work that belongs to the current hour.
3. Add or update automated tests for changed behavior.
4. Run available tests/CI and fix failures caused by the work.
5. Check adjacent systems for regressions.
6. Commit coherent changes.
7. Update the matching Notion task with deliverables, test status, blockers, and commit.
8. Advance only when the hour's acceptance criteria are verified.

## Release gate

The project is not called ready merely because code is committed. Before launch, the full 66-hour plan must pass automated regression and the Android real-device gate. Device-only checks must remain explicitly blocked until an actual Android device run is performed.

## Current priorities

- Core gameplay loop and navigation
- Persistence and migration safety
- Puzzle/content integrity
- Progression, lives, hints, achievements, daily challenge
- Mobile UX, safe area, input and lifecycle behavior
- Runtime stability and performance
- Analytics/privacy/release configuration
- Full regression and Android release-candidate verification
