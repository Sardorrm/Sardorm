from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class AchievementManagerContractTests(unittest.TestCase):
    def test_persisted_unlocks_are_sanitized_to_known_unique_ids(self):
        code = (ROOT / "src" / "achievement_manager.gd").read_text(encoding="utf-8")
        self.assertIn('unlocked = _sanitize_unlocked(data.get("unlocked", []))', code)
        self.assertIn('if _is_known_id(id) and not result.has(id):', code)
        self.assertIn('func _is_known_id(id: String) -> bool:', code)

    def test_persisted_counters_cannot_be_negative(self):
        code = (ROOT / "src" / "achievement_manager.gd").read_text(encoding="utf-8")
        self.assertIn('streak = maxi(0, int(data.get("streak", 0)))', code)
        self.assertIn('hints_free_solved = maxi(0, int(data.get("hints_free_solved", 0)))', code)

    def test_unlock_catalog_has_stable_source_of_truth(self):
        code = (ROOT / "src" / "achievement_manager.gd").read_text(encoding="utf-8")
        self.assertIn('const DEFINITIONS := [', code)
        self.assertIn('func get_definitions() -> Array:', code)
        self.assertIn('return DEFINITIONS.duplicate(true)', code)


if __name__ == "__main__":
    unittest.main()
