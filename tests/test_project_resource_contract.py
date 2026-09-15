import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "project.godot"

AUTOLOAD_RE = re.compile(r'^([A-Za-z0-9_]+)="\*res://([^"\\]+)"$', re.MULTILINE)
MAIN_SCENE_RE = re.compile(r'^run/main_scene="res://([^"\\]+)"$', re.MULTILINE)
THEME_RE = re.compile(r'^theme/custom="res://([^"\\]+)"$', re.MULTILINE)
ICON_RE = re.compile(r'^config/icon="res://([^"\\]+)"$', re.MULTILINE)


class ProjectResourceContractTests(unittest.TestCase):
    def setUp(self):
        self.text = PROJECT.read_text(encoding="utf-8")

    def _assert_resource(self, relative_path, label):
        path = ROOT / relative_path
        self.assertTrue(path.is_file(), f"Missing {label} resource: {relative_path}")

    def test_main_scene_exists(self):
        match = MAIN_SCENE_RE.search(self.text)
        self.assertIsNotNone(match, "project.godot must declare run/main_scene")
        self._assert_resource(match.group(1), "main scene")

    def test_theme_and_launcher_icon_exist(self):
        theme = THEME_RE.search(self.text)
        icon = ICON_RE.search(self.text)
        self.assertIsNotNone(theme, "project.godot must declare a custom theme")
        self.assertIsNotNone(icon, "project.godot must declare a launcher icon")
        self._assert_resource(theme.group(1), "theme")
        self._assert_resource(icon.group(1), "launcher icon")

    def test_all_autoload_scripts_exist(self):
        matches = AUTOLOAD_RE.findall(self.text)
        self.assertGreaterEqual(len(matches), 8, "Expected the release-critical autoload set")
        for name, resource in matches:
            with self.subTest(autoload=name):
                self._assert_resource(resource, f"autoload {name}")


if __name__ == "__main__":
    unittest.main()
