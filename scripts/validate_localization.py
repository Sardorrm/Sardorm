#!/usr/bin/env python3
"""Validate the runtime locale contract and shared puzzle translation catalog."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUNTIME = ROOT / "src/locale_runtime_fixed.gd"
CATALOG = ROOT / "src/puzzle_translations.gd"


def main() -> int:
    runtime = RUNTIME.read_text(encoding="utf-8")
    catalog = CATALOG.read_text(encoding="utf-8")

    assert 'const LANGUAGES: Array[String] = ["uz", "ru", "en"]' in runtime
    assert 'const PUZZLE_TRANSLATIONS = preload("res://src/puzzle_translations.gd")' in runtime
    assert 'if language == "uz":' in runtime
    assert 'PuzzleTranslations.get(puzzle_id, language, "")' in runtime
    assert 'if normalized not in LANGUAGES:' in runtime
    assert 'var settings: Dictionary = raw_settings.duplicate(true) if raw_settings is Dictionary else {}' in runtime

    ids = re.findall(r'"(mvp-\d{3})":\s*\{"ru":\s*".*?",\s*"en":\s*".*?"\}', catalog)
    assert len(ids) >= 20, f"expected at least 20 translated puzzles, found {len(ids)}"
    assert len(ids) == len(set(ids)), "duplicate translated puzzle IDs"
    expected = {f"mvp-{n:03d}" for n in range(11, 31)}
    assert expected <= set(ids), "mvp-011..mvp-030 translation coverage is incomplete"
    assert 'static func get(puzzle_id: String, language: String, fallback: String) -> String:' in catalog
    assert 'var translations: Dictionary = TEXTS[puzzle_id]' in catalog

    print(f"Validated locale runtime and {len(ids)} shared puzzle translations")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
