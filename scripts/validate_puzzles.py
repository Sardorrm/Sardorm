#!/usr/bin/env python3
"""Validate MindShift puzzle content and print a compact audit summary."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PUZZLES_PATH = ROOT / "data" / "puzzles.json"

REQUIRED = ("id", "category", "difficulty", "prompt", "answer", "hint", "explanation")
VALID_TYPES = {"choice", "true_false"}


def validate(data: dict) -> list[str]:
    errors: list[str] = []
    puzzles = data.get("puzzles")
    if not isinstance(puzzles, list) or not puzzles:
        return ["puzzles must be a non-empty array"]

    ids: set[str] = set()
    for index, puzzle in enumerate(puzzles, 1):
        prefix = f"puzzle #{index}"
        if not isinstance(puzzle, dict):
            errors.append(f"{prefix}: must be an object")
            continue
        for field in REQUIRED:
            if field not in puzzle:
                errors.append(f"{prefix}: missing {field}")
        pid = puzzle.get("id")
        if not isinstance(pid, str) or not pid.strip():
            errors.append(f"{prefix}: id must be a non-empty string")
        elif pid in ids:
            errors.append(f"{prefix}: duplicate id {pid}")
        else:
            ids.add(pid)
        difficulty = puzzle.get("difficulty")
        if not isinstance(difficulty, int) or isinstance(difficulty, bool) or not 1 <= difficulty <= 5:
            errors.append(f"{prefix} ({pid}): difficulty must be an integer 1..5")
        for field in ("category", "prompt", "hint", "explanation"):
            if not isinstance(puzzle.get(field), str) or not puzzle[field].strip():
                errors.append(f"{prefix} ({pid}): {field} must be non-empty text")

        answer_type = puzzle.get("answer_type")
        if answer_type is not None and answer_type not in VALID_TYPES:
            errors.append(f"{prefix} ({pid}): unsupported answer_type {answer_type!r}")

        answers = puzzle.get("answers")
        if answers is not None:
            if not isinstance(answers, list) or not answers:
                errors.append(f"{prefix} ({pid}): answers must be a non-empty array")
            else:
                if any(not isinstance(value, (str, int, float, bool)) for value in answers):
                    errors.append(f"{prefix} ({pid}): answers contains unsupported values")
                if puzzle.get("answer") not in answers:
                    errors.append(f"{prefix} ({pid}): answer must be present in answers")
        if answer_type in VALID_TYPES and not isinstance(answers, list):
            errors.append(f"{prefix} ({pid}): answer_type requires answers")

    return errors


def main() -> int:
    try:
        data = json.loads(PUZZLES_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"ERROR: cannot read {PUZZLES_PATH}: {exc}")
        return 1
    errors = validate(data)
    if errors:
        print("Puzzle validation FAILED")
        for error in errors:
            print(f"- {error}")
        return 1
    puzzles = data["puzzles"]
    by_difficulty = {level: sum(p["difficulty"] == level for p in puzzles) for level in range(1, 6)}
    print(f"Puzzle validation OK: {len(puzzles)} puzzles; difficulty distribution={by_difficulty}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
