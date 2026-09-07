from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class DailyStreakContractTests(unittest.TestCase):
    def test_daily_refreshes_when_read_from_ui(self):
        code = (ROOT / "src" / "daily_challenge_service.gd").read_text(encoding="utf-8")
        self.assertIn("func get_puzzles() -> Array:", code)
        self.assertIn("refresh()", code.split("func get_puzzles() -> Array:", 1)[1].split("func reset_progress", 1)[0])
        self.assertIn("func is_completed() -> bool:", code)
        self.assertIn("refresh()", code.split("func is_completed() -> bool:", 1)[1].split("func is_session_completed", 1)[0])

    def test_daily_failures_are_retryable(self):
        code = (ROOT / "src" / "daily_challenge_service.gd").read_text(encoding="utf-8")
        failed = code.split("func record_failed() -> void:", 1)[1].split("func is_completed", 1)[0]
        self.assertNotIn("current_position +=", failed)
        self.assertIn("clampi(current_position, 0, current_indices.size())", failed)

    def test_daily_completed_dates_are_sanitized(self):
        code = (ROOT / "src" / "daily_challenge_service.gd").read_text(encoding="utf-8")
        self.assertIn("_sanitize_completed_dates", code)
        self.assertIn("not result.has(key)", code)
        self.assertIn("_is_valid_date_key", code)

    def test_streak_rejects_corrupt_date_state(self):
        code = (ROOT / "src" / "streak_manager.gd").read_text(encoding="utf-8")
        self.assertIn("if not _is_valid_date_key(last_completed_date):", code)
        self.assertIn("current_streak = 0", code)
        self.assertIn("if not _is_valid_date_key(date_key)", code)

    def test_streak_multipliers_remain_stable(self):
        code = (ROOT / "src" / "streak_manager.gd").read_text(encoding="utf-8")
        self.assertIn("if current_streak >= 7:", code)
        self.assertIn("return 2.0", code)
        self.assertIn("if current_streak >= 3:", code)
        self.assertIn("return 1.5", code)


if __name__ == "__main__":
    unittest.main()
