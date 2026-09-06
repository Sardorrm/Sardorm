import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = json.loads((ROOT / "data/puzzles.json").read_text(encoding="utf-8"))
PUZZLES = DATA["puzzles"]
REQUIRED = {"id", "category", "difficulty", "prompt", "answer", "hint"}


def test_puzzle_schema_and_ids():
    assert isinstance(PUZZLES, list)
    assert len(PUZZLES) >= 10
    ids = []
    for puzzle in PUZZLES:
        assert REQUIRED.issubset(puzzle), puzzle
        assert isinstance(puzzle["id"], str) and puzzle["id"].strip()
        assert isinstance(puzzle["prompt"], str) and puzzle["prompt"].strip()
        assert isinstance(puzzle["hint"], str) and puzzle["hint"].strip()
        assert isinstance(puzzle["answer"], (str, int, float))
        assert puzzle["difficulty"] in {"easy", "medium", "hard", "expert"}
        ids.append(puzzle["id"])
    assert len(ids) == len(set(ids)), "Duplicate puzzle IDs"


def test_puzzle_answers_are_non_empty():
    for puzzle in PUZZLES:
        answer = puzzle["answer"]
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
