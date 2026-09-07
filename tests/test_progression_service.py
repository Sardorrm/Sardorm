from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class ProgressionServiceContractTests(unittest.TestCase):
    def test_correct_campaign_answers_mark_level_complete(self):
        code = (ROOT / "src" / "progression_service.gd").read_text(encoding="utf-8")
        self.assertIn("if mark_campaign_level and level_manager != null:", code)
        self.assertIn("level_manager.mark_completed(level_index)", code)

    def test_daily_answers_do_not_force_campaign_progression(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        self.assertIn("not daily_mode", main)
        self.assertIn("progression.record_attempt(active_puzzle, true", main)

    def test_failures_reset_perfect_run_and_record_stats(self):
        code = (ROOT / "src" / "progression_service.gd").read_text(encoding="utf-8")
        self.assertIn("stats_manager.record_failed(puzzle.category, elapsed)", code)
        self.assertIn("achievement_manager.on_failed()", code)

    def test_new_achievements_emit_event(self):
        code = (ROOT / "src" / "progression_service.gd").read_text(encoding="utf-8")
        self.assertIn("for achievement_id in result.newly_unlocked:", code)
        self.assertIn("achievement_unlocked.emit(achievement_id)", code)


if __name__ == "__main__":
    unittest.main()
