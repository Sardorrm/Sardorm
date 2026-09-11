# Versioning and build reproducibility

MindShift keeps the release version in one committed source: `project.godot` → `[application]` → `config/version`.

## Current release version

The current version is **0.1.0**. `scripts/validate_versioning.py` enforces `MAJOR.MINOR.PATCH` SemVer syntax and prints the resolved version for CI/release tooling.

## Reproducible rules

- Do not derive the application version from wall-clock time, machine-local state, or an uncommitted file.
- CI may set `MINDSHIFT_VERSION` to pin an expected release version; validation fails if it differs from `project.godot`.
- Keep version changes as explicit commits so a release can be traced to an exact Git commit.
- Android version-code/signing configuration belongs in the eventual Android export preset and release credentials; secrets must never be committed.
- A physical Android install/run is a separate release gate and is not claimed by source-only CI.

## Verification

Run:

```text
python scripts/validate_versioning.py
MINDSHIFT_VERSION=0.1.0 python scripts/validate_versioning.py
python scripts/run_tests.py
```

The first two commands must report the same `MINDSHIFT_VERSION=0.1.0`. The test suite must pass before this roadmap hour is accepted.
