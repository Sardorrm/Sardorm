import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class ProgressionContractTests(unittest.TestCase):
    def test_progression_matches_stats_api(self):
        progression = (ROOT / "src" / "progression_service.gd").read_text(encoding="utf-8")
        stats = (ROOT / "src" / "stats_manager.gd").read_text(encoding="utf-8")
        self.assertIn("stats_manager.record_solved(elapsed, puzzle.category)", progression)
        self.assertNotIn("stats_manager.record_solved(elapsed, puzzle.category, result.score)", progression)
        self.assertIn("func record_solved(seconds: float, category: String = \"\")", stats)

    def test_daily_achievement_contract(self):
        achievements = (ROOT / "src" / "achievement_manager.gd").read_text(encoding="utf-8")
        progression = (ROOT / "src" / "progression_service.gd").read_text(encoding="utf-8")
        self.assertIn('"daily_3"', achievements)
        self.assertIn('"daily_7"', achievements)
        self.assertIn("func on_daily_completed(current_streak: int)", achievements)
        self.assertIn("func record_daily_completion(current_streak: int)", progression)

    def test_achievement_definitions_are_exposed(self):
        achievements = (ROOT / "src" / "achievement_manager.gd").read_text(encoding="utf-8")
        self.assertIn("func get_definitions() -> Array", achievements)
        self.assertIn("func is_unlocked(id: String) -> bool", achievements)


if __name__ == "__main__":
    unittest.main()
