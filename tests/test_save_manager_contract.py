from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SAVE_MANAGER = ROOT / "src" / "save_manager.gd"


class SaveManagerContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.source = SAVE_MANAGER.read_text(encoding="utf-8")

    def test_save_format_is_versioned_and_has_language_default(self):
        self.assertIn("const SAVE_VERSION := 6", self.source)
        self.assertIn('"language": "uz"', self.source)
        self.assertIn('result["version"] = SAVE_VERSION', self.source)

    def test_completed_levels_are_normalized(self):
        self.assertIn("func _normalize_completed_levels(value) -> Array:", self.source)
        self.assertIn("if level < 0 or seen.has(level):", self.source)
        self.assertIn("normalized.sort()", self.source)
        self.assertIn('result["completed_levels"] = _normalize_completed_levels(', self.source)

    def test_settings_language_is_safe_and_deterministic(self):
        self.assertIn("func _normalize_settings(value, defaults: Dictionary) -> Dictionary:", self.source)
        self.assertIn('if language not in ["uz", "ru", "en"]:', self.source)
        self.assertIn('language = "uz"', self.source)
        self.assertIn('settings["sound"] = bool(settings.get("sound", true))', self.source)
        self.assertIn('settings["haptics"] = bool(settings.get("haptics", true))', self.source)

    def test_save_path_and_corrupt_fallback_remain_guarded(self):
        self.assertIn('const SAVE_PATH := "user://mindshift_save.json"', self.source)
        self.assertIn('if not FileAccess.file_exists(SAVE_PATH):', self.source)
        self.assertIn('if typeof(data) != TYPE_DICTIONARY:', self.source)
        self.assertIn('return defaults', self.source)


if __name__ == "__main__":
    unittest.main()
