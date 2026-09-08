import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]


class SaveManagerContractTests(unittest.TestCase):
    def test_save_schema_is_versioned(self):
        code = (ROOT / "src" / "save_manager.gd").read_text(encoding="utf-8")
        self.assertIn("const SAVE_VERSION := 6", code)
        self.assertIn('"version": SAVE_VERSION', code)
        self.assertIn("static func load_progress()", code)
        self.assertIn("static func save_progress(", code)

    def test_legacy_save_fields_have_safe_defaults(self):
        code = (ROOT / "src" / "save_manager.gd").read_text(encoding="utf-8")
        for token in [
            'data.get("completed_levels", data.get("completed", []))',
            'data.get("hints_used", 0)',
            'data.get("settings", {})',
            'defaults["settings"].merged(settings)',
            'result["version"] = SAVE_VERSION',
        ]:
            self.assertIn(token, code)

    def test_migration_guards_older_schema_versions(self):
        code = (ROOT / "src" / "save_manager.gd").read_text(encoding="utf-8")
        self.assertIn('var source_version := int(data.get("version", 1))', code)
        self.assertIn('if source_version < 5 and result["streak"].is_empty():', code)
        self.assertIn('if source_version < 4 and result["lives"].is_empty():', code)

    def test_corrupt_or_unreadable_save_falls_back_to_defaults(self):
        code = (ROOT / "src" / "save_manager.gd").read_text(encoding="utf-8")
        self.assertIn("if file == null:", code)
        self.assertIn("return defaults", code)
        self.assertIn("if typeof(data) != TYPE_DICTIONARY:", code)
        self.assertIn("var result := defaults.duplicate(true)", code)

    def test_new_progression_domains_are_persisted(self):
        code = (ROOT / "src" / "save_manager.gd").read_text(encoding="utf-8")
        for key in ["stats", "achievements", "daily_challenges", "streak", "lives", "settings"]:
            self.assertIn('"%s"' % key, code)


if __name__ == "__main__":
    unittest.main()
