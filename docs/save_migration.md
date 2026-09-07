# MindShift Save Migration Contract

## Current schema

`SaveManager` writes `version` and currently uses `SAVE_VERSION := 6`.

## Migration rules

- Missing save file returns a complete default save.
- Invalid JSON or a non-dictionary root falls back to defaults.
- Missing legacy fields receive safe defaults.
- Legacy `completed` is accepted as `completed_levels`.
- Loaded data is normalized to the current save version.
- Settings are merged with current defaults so newly introduced settings survive old saves.
- New progression domains (`stats`, `achievements`, `daily_challenges`, `streak`, `lives`) receive defaults when absent.

## Verification gate

The automated contract tests in `tests/test_save_manager.py` verify versioning, legacy defaults, and persistence domains. A real Android run is still required before release to verify persistence across app restart and platform-specific storage behavior.

## Blocker

Do not mark the migration task as fully release-verified until Android persistence has been exercised on a real device.
