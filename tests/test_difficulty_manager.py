from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


class DifficultyManagerContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.code = (ROOT / "src" / "difficulty_manager.gd").read_text(encoding="utf-8")

    def test_all_five_tiers_have_explicit_progression_data(self):
        for level in range(1, 6):
            self.assertRegex(self.code, rf"{level}: \"[^\"]+\"")
            self.assertRegex(self.code, rf"{level}: \d+")
            self.assertRegex(self.code, rf"{level}: \d+\.\d+")

    def test_time_limits_get_stricter_and_scores_get_higher(self):
        time_values = [int(value) for value in re.search(r"const TIME_LIMITS := \{([^}]+)\}", self.code).group(1).split(',') if ':' in value for value in [value.split(':', 1)[1].strip()]]
        score_values = [float(value) for value in re.search(r"const SCORE_MULTIPLIERS := \{([^}]+)\}", self.code).group(1).split(',') if ':' in value for value in [value.split(':', 1)[1].strip()]]
        self.assertEqual(time_values, sorted(time_values, reverse=True))
        self.assertEqual(score_values, sorted(score_values))
        self.assertGreater(score_values[-1], score_values[0])

    def test_public_helpers_keep_inputs_inside_supported_tiers(self):
        self.assertIn("clampi(difficulty, 1, 5)", self.code)
        self.assertIn("if puzzle == null:", self.code)
        self.assertIn("return 0", self.code)

    def test_custom_puzzle_time_overrides_tier_default(self):
        self.assertIn("if puzzle.time_limit_seconds > 0:", self.code)
        self.assertIn("return int(puzzle.time_limit_seconds)", self.code)


if __name__ == "__main__":
    unittest.main()
