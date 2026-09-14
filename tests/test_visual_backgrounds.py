from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


class VisualBackgroundContractTests(unittest.TestCase):
    def test_background_manager_declares_local_default_and_category_assets(self):
        code = (ROOT / "src" / "visual_backgrounds.gd").read_text(encoding="utf-8")
        self.assertIn('const DEFAULT_BG := "res://assets/backgrounds/mindshift_cognitive_bg.svg"', code)
        for category in ["PATTERN", "LOGIC", "OBSERVATION", "SPATIAL", "ASSUMPTION", "MINDSHIFT"]:
            self.assertIn(f'"{category}": "res://assets/backgrounds/', code)

    def test_declared_background_assets_exist_and_are_svg(self):
        code = (ROOT / "src" / "visual_backgrounds.gd").read_text(encoding="utf-8")
        paths = re.findall(r'res://assets/backgrounds/[^"\\]+\.svg', code)
        self.assertGreaterEqual(len(paths), 7)
        for resource_path in sorted(set(paths)):
            local = ROOT / resource_path.removeprefix("res://")
            self.assertTrue(local.is_file(), f"Missing visual asset: {resource_path}")
            self.assertGreater(local.stat().st_size, 100, f"Asset is unexpectedly empty: {resource_path}")

    def test_background_is_non_interactive_and_cover_scaled(self):
        code = (ROOT / "src" / "visual_backgrounds.gd").read_text(encoding="utf-8")
        self.assertIn("background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED", code)
        self.assertIn("background.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR", code)
        self.assertIn("background.mouse_filter = Control.MOUSE_FILTER_IGNORE", code)
        self.assertIn("background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)", code)
        self.assertIn("background.z_index = -10", code)

    def test_category_detection_is_deterministic_and_avoids_redundant_switches(self):
        code = (ROOT / "src" / "visual_backgrounds.gd").read_text(encoding="utf-8")
        self.assertIn("func _category_from_label(value: String) -> String:", code)
        self.assertIn("var category := _category_from_label(node.text)", code)
        self.assertIn("if category.is_empty() or category == _last_category:", code)
        self.assertIn("_last_category = category", code)

    def test_category_switch_only_uses_declared_local_paths(self):
        code = (ROOT / "src" / "visual_backgrounds.gd").read_text(encoding="utf-8")
        self.assertIn("_set_background(CATEGORY_BGS[category])", code)
        self.assertNotIn("http://", code)
        self.assertNotIn("https://", code)


if __name__ == "__main__":
    unittest.main()
