import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class ProgressionRewardContractTests(unittest.TestCase):
    def test_score_is_persisted_and_recorded(self):
        stats = (ROOT / "src" / "stats_manager.gd").read_text(encoding="utf-8")
        progression = (ROOT / "src" / "progression_service.gd").read_text(encoding="utf-8")
        self.assertIn("var total_score := 0", stats)
        self.assertIn('data.get("total_score", 0)', stats)
        self.assertIn('"total_score": total_score', stats)
        self.assertIn("record_solved(elapsed, puzzle.category, result.score)", progression)

    def test_daily_achievement_milestones_exist(self):
        achievements = (ROOT / "src" / "achievement_manager.gd").read_text(encoding="utf-8")
        progression = (ROOT / "src" / "progression_service.gd").read_text(encoding="utf-8")
        self.assertIn('"daily_3"', achievements)
        self.assertIn('"daily_7"', achievements)
        self.assertIn("func on_daily_completed(current_streak: int)", achievements)
        self.assertIn("func record_daily_completion(current_streak: int)", progression)

    def test_achievement_catalog_is_queryable(self):
        achievements = (ROOT / "src" / "achievement_manager.gd").read_text(encoding="utf-8")
        self.assertIn("func get_definitions() -> Array", achievements)
        self.assertIn("func is_unlocked(id: String) -> bool", achievements)


if __name__ == "__main__":
    unittest.main()
