#!/usr/bin/env python3
"""Release-critical repository invariants for the MindShift stability gate."""
from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "project.godot"


class StabilityInvariantTests(unittest.TestCase):
    def test_project_declares_existing_main_scene_and_theme(self) -> None:
        text = PROJECT.read_text(encoding="utf-8")
        for key in ("run/main_scene", "theme/custom"):
            match = re.search(rf"^{re.escape(key)}=\"([^\"]+)\"$", text, re.MULTILINE)
            self.assertIsNotNone(match, f"Missing {key} in project.godot")
            resource = match.group(1)
            self.assertTrue(resource.startswith("res://"), resource)
            target = ROOT / resource.removeprefix("res://")
            self.assertTrue(target.is_file(), f"Missing project resource: {resource}")

    def test_declared_autoloads_exist(self) -> None:
        text = PROJECT.read_text(encoding="utf-8")
        autoloads = re.findall(r'^\w+="\*res://([^\"]+)"$', text, re.MULTILINE)
        self.assertGreater(len(autoloads), 0)
        for relative_path in autoloads:
            self.assertTrue(
                (ROOT / relative_path).is_file(),
                f"Missing autoload script: res://{relative_path}",
            )

    def test_puzzle_catalog_exists_and_is_non_empty(self) -> None:
        catalog = ROOT / "data" / "puzzles.json"
        self.assertTrue(catalog.is_file(), "Missing puzzle catalog")
        self.assertGreater(catalog.stat().st_size, 0, "Puzzle catalog is empty")

    def test_godot_project_uses_mobile_safe_rendering(self) -> None:
        text = PROJECT.read_text(encoding="utf-8")
        self.assertIn('renderer/rendering_method="gl_compatibility"', text)
        self.assertIn('renderer/rendering_method.mobile="gl_compatibility"', text)
        self.assertIn('handheld/orientation=1', text)
        self.assertIn('stretch/mode="canvas_items"', text)


if __name__ == "__main__":
    unittest.main()
