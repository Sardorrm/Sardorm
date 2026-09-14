import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class LocaleRuntimeContractTests(unittest.TestCase):
    def test_three_languages_and_persistent_selector_contract(self):
        code = (ROOT / "src" / "locale_runtime_fixed.gd").read_text(encoding="utf-8")
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn('const LANGUAGES := ["uz", "ru", "en"]', code)
        self.assertIn('"DAVOM ETISH":"ПРОДОЛЖИТЬ"', code)
        self.assertIn('"DAVOM ETISH":"CONTINUE"', code)
        self.assertIn('func set_language(next_language: String) -> void:', code)
        self.assertIn('settings["language"] = language', code)
        self.assertIn('MindShiftLocaleRuntime="*res://src/locale_runtime_fixed.gd"', project)

    def test_selector_has_all_language_buttons_and_safe_default(self):
        code = (ROOT / "src" / "locale_runtime_fixed.gd").read_text(encoding="utf-8")
        self.assertIn('var stored := str(data.get("settings", {}).get("language", "uz"))', code)
        self.assertIn('language = stored if stored in LANGUAGES else "uz"', code)
        self.assertIn('for code in LANGUAGES:', code)
        self.assertIn('button.name = "Language_" + code', code)

    def test_language_switch_is_reversible_for_dynamic_ui(self):
        code = (ROOT / "src" / "locale_runtime_fixed.gd").read_text(encoding="utf-8")
        self.assertIn('get_meta("mindshift_locale_key", b.text)', code)
        self.assertIn('b.set_meta("mindshift_locale_key", key)', code)
        self.assertIn('get_meta("mindshift_locale_key", l.text)', code)
        self.assertIn('l.set_meta("mindshift_locale_key", label_key)', code)
        self.assertIn('get_meta("mindshift_locale_key", e.placeholder_text)', code)

    def test_broken_duplicate_runtime_was_removed(self):
        self.assertFalse((ROOT / "src" / "locale_runtime.gd").exists())


if __name__ == "__main__":
    unittest.main()
