#!/usr/bin/env python3
"""Regression checks for release-critical Android application metadata."""
from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "project.godot"
EXPORT_PRESETS = ROOT / "export_presets.cfg"


class AndroidPackageMetadataTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.project_text = PROJECT.read_text(encoding="utf-8")

    def test_application_name_is_release_identity(self) -> None:
        self.assertRegex(self.project_text, r'^config/name="MindShift"$', re.MULTILINE)

    def test_application_version_is_semver(self) -> None:
        match = re.search(r'^config/version="([^"]+)"$', self.project_text, re.MULTILINE)
        self.assertIsNotNone(match, "Missing application version")
        self.assertRegex(match.group(1), r"^\d+\.\d+\.\d+$")

    def test_android_release_preset_is_never_silent_about_identity(self) -> None:
        if not EXPORT_PRESETS.exists():
            self.skipTest("Android export preset is an external release-account gate")
        text = EXPORT_PRESETS.read_text(encoding="utf-8")
        android_sections = re.findall(
            r"\[preset\.[^\]]+\]\s*(.*?)(?=\n\[preset\.|\Z)",
            text,
            re.DOTALL,
        )
        android = [section for section in android_sections if 'platform="Android"' in section]
        self.assertTrue(android, "Android export preset is missing")
        self.assertTrue(
            any("package/unique_name" in section for section in android),
            "Android preset must declare package/unique_name",
        )

    def test_project_does_not_contain_release_secrets(self) -> None:
        forbidden = ("keystore_password", "key_password", "store_password")
        lowered = self.project_text.lower()
        for marker in forbidden:
            self.assertNotIn(marker, lowered)


if __name__ == "__main__":
    unittest.main()
