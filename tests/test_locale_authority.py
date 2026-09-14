import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class LocaleAuthorityContractTests(unittest.TestCase):
    def test_single_runtime_locale_autoload_is_authoritative(self):
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertNotIn('MindShiftLocale="*res://src/locale_manager.gd"', project)
        self.assertIn('MindShiftLocaleRuntime="*res://src/locale_runtime_fixed.gd"', project)
        self.assertIn('MindShiftMotion="*res://src/motion_manager.gd"', project)

    def test_puzzle_definition_uses_runtime_locale_service(self):
        code = (ROOT / "src/puzzle_definition.gd").read_text(encoding="utf-8")
        self.assertIn('get_node_or_null("MindShiftLocaleRuntime")', code)
        self.assertIn('locale.has_method("translate_puzzle_text")', code)
        self.assertIn('puzzle.prompt = locale.translate_puzzle_text', code)

    def test_runtime_locale_supports_shared_puzzle_translation_catalog_without_touching_answers(self):
        code = (ROOT / "src/locale_runtime_fixed.gd").read_text(encoding="utf-8")
        self.assertIn('func translate_puzzle_text(puzzle_id: String, fallback: String) -> String:', code)
        self.assertIn('const PUZZLE_TRANSLATIONS := preload("res://src/puzzle_translations.gd")', code)
        self.assertIn('PuzzleTranslations.get(puzzle_id, language, "")', code)
        self.assertIn('if language == "uz":', code)
        self.assertNotIn('answer =', code)


if __name__ == "__main__":
    unittest.main()
