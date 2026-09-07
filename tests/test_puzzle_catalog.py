import json
import pathlib
import unittest
from collections import Counter

ROOT = pathlib.Path(__file__).resolve().parents[1]


class PuzzleCatalogTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.data = json.loads((ROOT / "data" / "puzzles.json").read_text(encoding="utf-8"))
        cls.puzzles = cls.data["puzzles"]

    def test_catalog_has_unique_nonempty_ids(self):
        ids = [p.get("id") for p in self.puzzles]
        self.assertEqual(len(ids), len(set(ids)))
        self.assertTrue(all(isinstance(pid, str) and pid.strip() for pid in ids))

    def test_every_puzzle_has_required_content(self):
        required = {"id", "category", "difficulty", "prompt", "answer", "hint", "explanation"}
        for puzzle in self.puzzles:
            self.assertTrue(required.issubset(puzzle.keys()), puzzle.get("id"))
            for field in ("category", "prompt", "hint", "explanation"):
                self.assertIsInstance(puzzle[field], str)
                self.assertTrue(puzzle[field].strip(), puzzle["id"])

    def test_difficulty_is_in_range(self):
        self.assertTrue(all(isinstance(p["difficulty"], int) and 1 <= p["difficulty"] <= 5 for p in self.puzzles))

    def test_declared_answer_types_have_options_and_correct_answer(self):
        for puzzle in self.puzzles:
            answer_type = puzzle.get("answer_type")
            if answer_type is not None:
                self.assertIn(answer_type, {"choice", "true_false"}, puzzle["id"])
                self.assertIsInstance(puzzle.get("answers"), list, puzzle["id"])
                self.assertGreater(len(puzzle["answers"]), 0, puzzle["id"])
                self.assertIn(puzzle["answer"], puzzle["answers"], puzzle["id"])

    def test_catalog_is_not_accidentally_empty_or_tiny(self):
        self.assertGreaterEqual(len(self.puzzles), 50)

    def test_difficulty_distribution_is_balanced(self):
        counts = Counter(p["difficulty"] for p in self.puzzles)
        self.assertEqual(sum(counts.values()), 50)
        for difficulty in range(1, 6):
            self.assertGreaterEqual(counts[difficulty], 6, difficulty)

    def test_choice_puzzles_have_real_choice_metadata(self):
        for puzzle in self.puzzles:
            if puzzle.get("answer_type") == "choice":
                self.assertGreaterEqual(len(puzzle.get("answers", [])), 2, puzzle["id"])
                self.assertLessEqual(len(puzzle["answers"]), 5, puzzle["id"])


if __name__ == "__main__":
    unittest.main()
