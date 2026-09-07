from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class LevelProgressionContractTests(unittest.TestCase):
    def test_level_manager_sanitizes_saved_progress(self):
        code = (ROOT / "src" / "level_manager.gd").read_text(encoding="utf-8")
        self.assertIn("func _sanitize_completed(value) -> Array:", code)
        self.assertIn("if index >= 0 and index < puzzle_engine.puzzles.size() and not result.has(index):", code)
        self.assertIn("result.sort()", code)

    def test_unlock_requires_previous_level(self):
        code = (ROOT / "src" / "level_manager.gd").read_text(encoding="utf-8")
        self.assertIn("if index == 0:", code)
        self.assertIn("return completed_levels.has(index - 1)", code)

    def test_completed_level_advances_current_level(self):
        code = (ROOT / "src" / "level_manager.gd").read_text(encoding="utf-8")
        self.assertIn("if index + 1 < get_level_count():", code)
        self.assertIn("current_level = max(current_level, index + 1)", code)

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
