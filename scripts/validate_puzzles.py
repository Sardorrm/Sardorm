#!/usr/bin/env python3
"""Validate the complete MindShift puzzle catalog and print a compact audit summary."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACK_PATHS = (ROOT / "data" / "puzzles.json", ROOT / "data" / "puzzles_extra.json")
REQUIRED = ("id", "category", "difficulty", "prompt", "answer", "hint", "explanation")
VALID_TYPES = {"text", "number", "choice", "true_false"}


def validate(data: dict, *, source: str = "puzzles") -> list[str]:
    errors: list[str] = []
    puzzles = data.get("puzzles")
    if not isinstance(puzzles, list) or not puzzles:
        return [f"{source}: puzzles must be a non-empty array"]

    ids: set[str] = set()
    prompts: set[str] = set()
    for index, puzzle in enumerate(puzzles, 1):
        prefix = f"{source} puzzle #{index}"
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
        prompt = puzzle.get("prompt")
        if not isinstance(prompt, str) or not prompt.strip():
            errors.append(f"{prefix} ({pid}): prompt must be non-empty text")
        else:
            normalized_prompt = prompt.strip().casefold()
            if normalized_prompt in prompts:
                errors.append(f"{prefix} ({pid}): duplicate prompt")
            prompts.add(normalized_prompt)
        difficulty = puzzle.get("difficulty")
        if not isinstance(difficulty, int) or isinstance(difficulty, bool) or not 1 <= difficulty <= 5:
            errors.append(f"{prefix} ({pid}): difficulty must be an integer 1..5")
        for field in ("category", "hint", "explanation"):
            if not isinstance(puzzle.get(field), str) or not puzzle[field].strip():
                errors.append(f"{prefix} ({pid}): {field} must be non-empty text")

        answer = puzzle.get("answer")
        if isinstance(answer, bool) or not isinstance(answer, (str, int, float)):
            errors.append(f"{prefix} ({pid}): answer must be text or numeric")
        elif isinstance(answer, str) and not answer.strip():
            errors.append(f"{prefix} ({pid}): answer must be non-empty")

        answer_type = puzzle.get("answer_type")
        if answer_type is None:
            answer_type = "number" if isinstance(answer, (int, float)) and not isinstance(answer, bool) else "text"
        if answer_type not in VALID_TYPES:
            errors.append(f"{prefix} ({pid}): unsupported answer_type {answer_type!r}")

        answers = puzzle.get("answers")
        if answers is not None:
            if not isinstance(answers, list) or not answers:
                errors.append(f"{prefix} ({pid}): answers must be a non-empty array")
            else:
                normalized_answers = [str(value).strip().casefold() for value in answers]
                if any(not value for value in normalized_answers):
                    errors.append(f"{prefix} ({pid}): answers cannot contain empty values")
                if len(normalized_answers) != len(set(normalized_answers)):
                    errors.append(f"{prefix} ({pid}): duplicate accepted answer")
                if answer_type in {"choice", "true_false"} and str(answer).strip().casefold() not in normalized_answers:
                    errors.append(f"{prefix} ({pid}): answer must be present in answers")
        if answer_type in {"choice", "true_false"} and not isinstance(answers, list):
            errors.append(f"{prefix} ({pid}): answer_type requires answers")
        if answer_type == "true_false" and [str(v).strip().casefold() for v in (answers or [])] != ["true", "false"]:
            errors.append(f"{prefix} ({pid}): true_false answers must be exactly true,false")

    return errors


def load_pack(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> int:
    all_puzzles: list[dict] = []
    all_ids: set[str] = set()
    all_prompts: set[str] = set()
    errors: list[str] = []
    for path in PACK_PATHS:
        try:
            data = load_pack(path)
        except (OSError, json.JSONDecodeError) as exc:
            errors.append(f"{path.relative_to(ROOT)}: cannot read JSON: {exc}")
            continue
        pack_errors = validate(data, source=str(path.relative_to(ROOT)))
        errors.extend(pack_errors)
        for puzzle in data.get("puzzles", []) if isinstance(data.get("puzzles"), list) else []:
            pid = puzzle.get("id") if isinstance(puzzle, dict) else None
            prompt = puzzle.get("prompt") if isinstance(puzzle, dict) else None
            if isinstance(pid, str) and pid in all_ids:
                errors.append(f"combined catalog: duplicate id {pid}")
            elif isinstance(pid, str):
                all_ids.add(pid)
            if isinstance(prompt, str):
                normalized_prompt = prompt.strip().casefold()
                if normalized_prompt in all_prompts:
                    errors.append("combined catalog: duplicate prompt")
                all_prompts.add(normalized_prompt)
            all_puzzles.append(puzzle)

    if errors:
        print("Puzzle validation FAILED")
        for error in errors:
            print(f"- {error}")
        return 1

    by_difficulty = {level: sum(p["difficulty"] == level for p in all_puzzles) for level in range(1, 6)}
    by_type = {}
    for puzzle in all_puzzles:
        answer = puzzle["answer"]
        answer_type = puzzle.get("answer_type", "number" if isinstance(answer, (int, float)) and not isinstance(answer, bool) else "text")
        by_type[answer_type] = by_type.get(answer_type, 0) + 1
    print(f"Puzzle validation OK: {len(all_puzzles)} puzzles; difficulty distribution={by_difficulty}; answer types={by_type}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
