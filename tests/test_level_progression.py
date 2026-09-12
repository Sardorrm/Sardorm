from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class LevelProgressionContractTests(unittest.TestCase):
    def test_level_manager_sanitizes_saved_progress(self):
        code = (ROOT / "src" / "level_manager.gd").read_text(encoding="utf-8")
        self.assertIn("func _sanitize_completed(value) -> Array:", code)
        self.assertIn("var valid: Dictionary = {}", code)
        self.assertIn("if index >= 0 and index < puzzle_engine.puzzles.size():", code)
        self.assertIn("for index in range(puzzle_engine.puzzles.size()):", code)
        self.assertIn("if not valid.has(index):", code)

    def test_malformed_saved_completion_gap_cannot_skip_campaign_levels(self):
        code = (ROOT / "src" / "level_manager.gd").read_text(encoding="utf-8")
        self.assertIn("# Campaign unlocks are sequential.", code)
        self.assertIn("if not valid.has(index):\n            break", code)
        self.assertNotIn("result.sort()\n    return result", code)

    def test_current_level_is_capped_to_unlocked_frontier(self):
        code = (ROOT / "src" / "level_manager.gd").read_text(encoding="utf-8")
        self.assertIn("var requested_level: int = clampi(int(save_data.get(\"current_level\", 0))", code)
        self.assertIn("current_level = mini(requested_level, completed_levels.size())", code)

    def test_unlock_requires_previous_level(self):
        code = (ROOT / "src" / "level_manager.gd").read_text(encoding="utf-8")
        self.assertIn("if index == 0:", code)
        self.assertIn("return completed_levels.has(index - 1)", code)

    def test_completed_level_advances_current_level(self):
        code = (ROOT / "src" / "level_manager.gd").read_text(encoding="utf-8")
        self.assertIn("if index + 1 < get_level_count():", code)
        self.assertIn("current_level = maxi(current_level, index + 1)", code)

    def test_lives_are_bounded_and_recover_over_time(self):
        code = (ROOT / "src" / "life_manager.gd").read_text(encoding="utf-8")
        self.assertIn("const MAX_LIVES := 3", code)
        self.assertIn("const RECOVERY_SECONDS := 300", code)
        self.assertIn("lives = clampi(int(data.get(\"lives\", MAX_LIVES)), 0, MAX_LIVES)", code)
        self.assertIn("lives = mini(MAX_LIVES, lives + recovered)", code)

    def test_empty_lives_block_further_loss(self):
        code = (ROOT / "src" / "life_manager.gd").read_text(encoding="utf-8")
        self.assertIn("if lives <= 0:", code)
        self.assertIn("return false", code)


if __name__ == "__main__":
    unittest.main()
