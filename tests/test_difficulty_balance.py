from pathlib import Path
import json
import unittest

ROOT = Path(__file__).resolve().parents[1]


class DifficultyBalanceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        with (ROOT / "data" / "puzzles.json").open(encoding="utf-8") as handle:
            cls.puzzles = json.load(handle)["puzzles"]

    def test_catalog_uses_all_five_difficulty_tiers(self):
        counts = {level: 0 for level in range(1, 6)}
        for puzzle in self.puzzles:
            counts[int(puzzle["difficulty"])] += 1
        self.assertTrue(all(counts[level] > 0 for level in range(1, 6)), counts)

    def test_no_single_tier_dominates_catalog(self):
        counts = {level: 0 for level in range(1, 6)}
        for puzzle in self.puzzles:
            counts[int(puzzle["difficulty"])] += 1
        largest = max(counts.values())
        self.assertLessEqual(largest, len(self.puzzles) * 0.5, counts)

    def test_difficulty_values_are_in_supported_range(self):
        for puzzle in self.puzzles:
            self.assertIn(int(puzzle["difficulty"]), range(1, 6), puzzle["id"])

    def test_difficulty_manager_has_monotonic_timing_and_scoring(self):
        code = (ROOT / "src" / "difficulty_manager.gd").read_text(encoding="utf-8")
        self.assertIn("const TIME_LIMITS := {1: 90, 2: 75, 3: 60, 4: 50, 5: 40}", code)
        self.assertIn("const SCORE_MULTIPLIERS := {1: 1.0, 2: 1.15, 3: 1.35, 4: 1.6, 5: 2.0}", code)


if __name__ == "__main__":
    unittest.main()
