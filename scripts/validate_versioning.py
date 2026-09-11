#!/usr/bin/env python3
"""Validate deterministic application version metadata for release builds."""
from __future__ import annotations

import os
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "project.godot"
SEMVER = re.compile(r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$")


def project_version() -> str:
    text = PROJECT.read_text(encoding="utf-8")
    match = re.search(r'^config/version="([^"]+)"$', text, re.MULTILINE)
    assert match, "project.godot must define config/version"
    return match.group(1)


def main() -> int:
    version = project_version()
    assert SEMVER.fullmatch(version), f"Invalid release version: {version!r}; expected MAJOR.MINOR.PATCH"

    # CI/release tooling may explicitly pin the expected version. When absent,
    # the committed project.godot value is the deterministic source of truth.
    expected = os.environ.get("MINDSHIFT_VERSION")
    if expected:
        assert SEMVER.fullmatch(expected), f"Invalid MINDSHIFT_VERSION: {expected!r}"
        assert expected == version, f"MINDSHIFT_VERSION={expected} does not match project.godot={version}"

    print(f"MINDSHIFT_VERSION={version}")
    print("VERSION_SOURCE=project.godot")
    print("VERSION_REPRODUCIBLE=true")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
