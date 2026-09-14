from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class PuzzleTranslationCatalogTests(unittest.TestCase):
    def test_extended_catalog_has_russian_and_english_for_mvp_011_to_030(self):
        code = (ROOT / "src" / "puzzle_translations.gd").read_text(encoding="utf-8")
        for index in range(11, 31):
            puzzle_id = f'"mvp-{index:03d}"'
            self.assertIn(puzzle_id, code)
        self.assertGreaterEqual(code.count('"ru":'), 20)
        self.assertGreaterEqual(code.count('"en":'), 20)

    def test_runtime_uses_shared_catalog_before_legacy_fallback(self):
        code = (ROOT / "src" / "locale_runtime_fixed.gd").read_text(encoding="utf-8")
        self.assertIn('preload("res://src/puzzle_translations.gd")', code)
        self.assertIn('PuzzleTranslations.get(puzzle_id, language, "")', code)

    def test_save_defaults_keep_uzbek_as_language_without_resetting_progress(self):
        code = (ROOT / "src" / "save_manager.gd").read_text(encoding="utf-8")
        self.assertIn('"language": "uz"', code)
        self.assertIn('result["completed_levels"] = completed.duplicate()', code)


if __name__ == "__main__":
    unittest.main()
