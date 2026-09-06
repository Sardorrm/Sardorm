import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class RuntimeSettingsContractTests(unittest.TestCase):
    def test_haptics_setting_is_persisted_and_applied(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        save = (ROOT / "src" / "save_manager.gd").read_text(encoding="utf-8")
        polish = (ROOT / "src" / "ui_polish.gd").read_text(encoding="utf-8")
        self.assertIn('"haptics": true', main)
        self.assertIn('settings.get("haptics", true)', main)
        self.assertIn("set_haptics_enabled", main)
        self.assertIn('"haptics": true', save)
        self.assertIn("var haptics_enabled := true", polish)
        self.assertIn("if haptics_enabled", polish)

    def test_project_has_single_window_display_section(self):
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertEqual(project.count("[display/window]"), 1)
        self.assertNotIn("[display]\n", project)


if __name__ == "__main__":
    unittest.main()
