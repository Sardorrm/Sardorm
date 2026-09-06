import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = json.loads((ROOT / "data/puzzles.json").read_text(encoding="utf-8"))
PUZZLES = DATA["puzzles"]
REQUIRED = {"id", "category", "difficulty", "prompt", "answer", "hint"}


def test_puzzle_schema_and_ids():
    assert isinstance(PUZZLES, list)
    assert len(PUZZLES) >= 10
    ids = []
    prompts = []
    for puzzle in PUZZLES:
        assert REQUIRED.issubset(puzzle), puzzle
        assert isinstance(puzzle["id"], str) and puzzle["id"].strip()
        assert isinstance(puzzle["category"], str) and puzzle["category"].strip()
        assert isinstance(puzzle["prompt"], str) and puzzle["prompt"].strip()
        assert isinstance(puzzle["hint"], str) and puzzle["hint"].strip()
        assert isinstance(puzzle["answer"], (str, int, float))
        assert isinstance(puzzle["difficulty"], int) and 1 <= puzzle["difficulty"] <= 5
        if isinstance(puzzle["answer"], float):
            assert math.isfinite(puzzle["answer"])
        ids.append(puzzle["id"])
        prompts.append(puzzle["prompt"].strip().lower())
    assert len(ids) == len(set(ids)), "Duplicate puzzle IDs"
    assert len(prompts) == len(set(prompts)), "Duplicate puzzle prompts"


def test_puzzle_answers_are_non_empty():
    for puzzle in PUZZLES:
        answer = puzzle["answer"]
        assert str(answer).strip() != "", puzzle["id"]


def test_optional_answers_are_valid():
    for puzzle in PUZZLES:
        if "answers" in puzzle:
            assert isinstance(puzzle["answers"], list) and puzzle["answers"]
            for answer in puzzle["answers"]:
                assert str(answer).strip() != "", puzzle["id"]


def test_runtime_files_exist():
    for path in [
        ROOT / "src/puzzle_engine.gd",
        ROOT / "src/level_manager.gd",
        ROOT / "src/save_manager.gd",
        ROOT / "src/stats_manager.gd",
        ROOT / "src/main.gd",
    ]:
        assert path.exists(), path
