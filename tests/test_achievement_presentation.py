from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class AchievementPresentationContractTests(unittest.TestCase):
    def test_home_exposes_achievements_entry_point(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        self.assertIn('content.add_child(_button("YUTUQLAR", _show_achievements))', main)

    def test_achievements_screen_renders_catalog_and_unlock_state(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        self.assertIn('func _show_achievements() -> void:', main)
        self.assertIn('achievements.unlocked.size()', main)
        self.assertIn('achievements.is_unlocked(id)', main)
        self.assertIn('"✓" if achievements.is_unlocked(id) else "🔒"', main)

    def test_new_unlock_is_surfaced(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        self.assertIn('"🏆 Yangi yutuq ochildi!"', main)
        self.assertIn('"🏆 Yangi yutuq: %s" % _achievement_names(newly_daily)', main)

    def test_achievement_manager_is_source_of_truth(self):
        manager = (ROOT / "src" / "achievement_manager.gd").read_text(encoding="utf-8")
        self.assertIn('func is_unlocked(id: String) -> bool:', manager)
        self.assertIn('return unlocked.has(id)', manager)


if __name__ == "__main__":
    unittest.main()
