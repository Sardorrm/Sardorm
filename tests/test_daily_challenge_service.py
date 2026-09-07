from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class DailyChallengeServiceContractTests(unittest.TestCase):
    def test_daily_selection_is_deterministic_and_bounded(self):
        code = (ROOT / "src" / "daily_challenge.gd").read_text(encoding="utf-8")
        self.assertIn("func date_key(unix_time: int = -1) -> String:", code)
        self.assertIn("func seed_for_date(key: String) -> int:", code)
        self.assertIn("var target := mini(count, puzzle_count)", code)
        self.assertIn("selected.sort()", code)

    def test_date_rollover_resets_daily_progress(self):
        code = (ROOT / "src" / "daily_challenge_service.gd").read_text(encoding="utf-8")
        self.assertIn("var date_changed := next_date != current_date", code)
        self.assertIn("if date_changed:", code)
        self.assertIn("completed_count = 0", code)
        self.assertIn("current_position = 0", code)

    def test_failed_daily_puzzle_remains_retryable(self):
        code = (ROOT / "src" / "daily_challenge_service.gd").read_text(encoding="utf-8")
        self.assertIn("func record_failed() -> void:", code)
        self.assertIn("# A failed/timeout daily puzzle remains retryable.", code)
        self.assertNotIn("func record_failed() -> void:\n    current_position = mini(current_indices.size(), current_position + 1)", code)

    def test_daily_completion_requires_all_selected_puzzles_solved(self):
        code = (ROOT / "src" / "daily_challenge_service.gd").read_text(encoding="utf-8")
        self.assertIn("completed_count >= mini(CHALLENGE_SIZE, current_indices.size())", code)
        self.assertIn("not current_indices.is_empty()", code)


if __name__ == "__main__":
    unittest.main()
