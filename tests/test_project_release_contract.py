from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "project.godot"
SEMVER = re.compile(r'^config/version="(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)"$', re.MULTILINE)
MAIN_SCENE = re.compile(r'^run/main_scene="res://src/MainScene\.tscn"$', re.MULTILINE)
LAUNCHER_ICON = re.compile(r'^config/icon="res://assets/store/mindshift_launcher\.svg"$', re.MULTILINE)


class ProjectReleaseContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.text = PROJECT.read_text(encoding="utf-8")

    def test_android_first_project_metadata_is_complete(self) -> None:
        self.assertIn('config/name="MindShift"', self.text)
        self.assertRegex(self.text, MAIN_SCENE)
        self.assertRegex(self.text, LAUNCHER_ICON)
        self.assertIn('theme/custom="res://themes/mindshift_theme.tres"', self.text)

    def test_release_version_is_semver(self) -> None:
        self.assertRegex(self.text, SEMVER, "project.godot must expose a stable MAJOR.MINOR.PATCH version")

    def test_mobile_display_and_renderer_contract(self) -> None:
        self.assertIn("size/viewport_width=720", self.text)
        self.assertIn("size/viewport_height=1280", self.text)
        self.assertIn("handheld/orientation=1", self.text)
        self.assertIn('renderer/rendering_method="gl_compatibility"', self.text)
        self.assertIn('renderer/rendering_method.mobile="gl_compatibility"', self.text)

    def test_required_autoloads_remain_registered(self) -> None:
        for name in (
            "MindShiftUIPolish",
            "MindShiftStartupState",
            "MindShiftAppLifecycle",
            "MindShiftVisualBackgrounds",
            "MindShiftLocaleRuntime",
            "MindShiftSafeArea",
            "MindShiftMotion",
        ):
            self.assertRegex(self.text, re.compile(rf'^"?{re.escape(name)}"?=', re.MULTILINE))


if __name__ == "__main__":
    unittest.main()
