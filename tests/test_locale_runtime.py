import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class LocaleRuntimeContractTests(unittest.TestCase):
    def test_three_languages_and_persistent_selector_contract(self):
        code = (ROOT / "src" / "locale_runtime_fixed.gd").read_text(encoding="utf-8")
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn('const LANGUAGES: Array[String] = ["uz", "ru", "en"]', code)
        self.assertIn('"DAVOM ETISH":"ПРОДОЛЖИТЬ"', code)
        self.assertIn('"DAVOM ETISH":"CONTINUE"', code)
        self.assertIn('func set_language(next_language: String) -> void:', code)
        self.assertIn('settings["language"] = language', code)
        self.assertIn('MindShiftLocaleRuntime="*res://src/locale_runtime_fixed.gd"', project)

    def test_selector_has_all_language_buttons_and_safe_default(self):
        code = (ROOT / "src/locale_runtime_fixed.gd").read_text(encoding="utf-8")
        self.assertIn('var stored: String = str(raw_settings.get("language", "uz"))', code)
        self.assertIn('language = stored if stored in LANGUAGES else "uz"', code)
        self.assertIn('for code in LANGUAGES:', code)
        self.assertIn('button.name = "Language_" + code', code)

    def test_language_switch_is_reversible_for_dynamic_ui(self):
        code = (ROOT / "src/locale_runtime_fixed.gd").read_text(encoding="utf-8")
        self.assertIn('get_meta("mindshift_locale_key", button.text)', code)
        self.assertIn('button.set_meta("mindshift_locale_key", key)', code)
        self.assertIn('get_meta("mindshift_locale_key", label.text)', code)
        self.assertIn('label.set_meta("mindshift_locale_key", label_key)', code)
        self.assertIn('get_meta("mindshift_locale_key", edit.placeholder_text)', code)

    def test_runtime_avoids_untyped_inferred_values_at_variant_boundaries(self):
        code = (ROOT / "src/locale_runtime_fixed.gd").read_text(encoding="utf-8")
        self.assertIn('var table: Dictionary = TEXTS.get(language, TEXTS["uz"])', code)
        self.assertIn('var translated: String = PuzzleTranslations.get(puzzle_id, language, "")', code)
        self.assertIn('var title: Node = _find_settings_title(root)', code)

    def test_broken_duplicate_runtime_was_removed(self):
        self.assertFalse((ROOT / "src/locale_runtime.gd").exists())


if __name__ == "__main__":
    unittest.main()
