import json
import math
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = json.loads((ROOT / "data/puzzles.json").read_text(encoding="utf-8"))
PUZZLES = DATA["puzzles"]
REQUIRED = {"id", "category", "difficulty", "prompt", "answer", "hint"}


class PuzzleIntegrityTests(unittest.TestCase):
    def test_puzzle_schema_and_ids(self):
        self.assertIsInstance(PUZZLES, list)
        self.assertGreaterEqual(len(PUZZLES), 10)
        ids = []
        prompts = []
        for puzzle in PUZZLES:
            self.assertTrue(REQUIRED.issubset(puzzle), puzzle)
            self.assertIsInstance(puzzle["id"], str)
            self.assertTrue(puzzle["id"].strip())
            self.assertIsInstance(puzzle["category"], str)
            self.assertTrue(puzzle["category"].strip())
            self.assertIsInstance(puzzle["prompt"], str)
            self.assertTrue(puzzle["prompt"].strip())
            self.assertIsInstance(puzzle["hint"], str)
            self.assertTrue(puzzle["hint"].strip())
            self.assertIsInstance(puzzle["answer"], (str, int, float))
            self.assertIsInstance(puzzle["difficulty"], int)
            self.assertIn(puzzle["difficulty"], {1, 2, 3, 4, 5})
            if isinstance(puzzle["answer"], float):
                self.assertTrue(math.isfinite(puzzle["answer"]))
            ids.append(puzzle["id"])
            prompts.append(puzzle["prompt"].strip().lower())
        self.assertEqual(len(ids), len(set(ids)), "Duplicate puzzle IDs")
        self.assertEqual(len(prompts), len(set(prompts)), "Duplicate puzzle prompts")

    def test_puzzle_answers_are_non_empty(self):
        for puzzle in PUZZLES:
            self.assertTrue(str(puzzle["answer"]).strip(), puzzle["id"])

    def test_optional_answers_are_valid(self):
        for puzzle in PUZZLES:
            if "answers" in puzzle:
                self.assertIsInstance(puzzle["answers"], list)
                self.assertTrue(puzzle["answers"])
                for answer in puzzle["answers"]:
                    self.assertTrue(str(answer).strip(), puzzle["id"])

    def test_runtime_files_exist(self):
        for path in [
            ROOT / "src/puzzle_engine.gd",
            ROOT / "src/level_manager.gd",
            ROOT / "src/save_manager.gd",
            ROOT / "src/stats_manager.gd",
            ROOT / "src/main.gd",
        ]:
            self.assertTrue(path.exists(), path)


if __name__ == "__main__":
    unittest.main()
