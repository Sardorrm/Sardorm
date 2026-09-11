import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class StoreAssetTests(unittest.TestCase):
    def test_required_source_assets_exist_and_are_svg(self):
        required = [
            ROOT / "assets/store/mindshift_launcher.svg",
            ROOT / "assets/store/mindshift_adaptive_foreground.svg",
            ROOT / "assets/store/mindshift_feature_graphic.svg",
        ]
        for path in required:
            self.assertTrue(path.is_file(), f"missing store asset: {path}")
            text = path.read_text(encoding="utf-8")
            self.assertTrue(text.startswith("<svg "), f"not an SVG source: {path}")
            self.assertNotIn("debug", text.lower(), f"debug artwork in release asset: {path}")

    def test_store_asset_dimensions_match_declared_targets(self):
        expected = {
            "mindshift_launcher.svg": (512, 512),
            "mindshift_adaptive_foreground.svg": (432, 432),
            "mindshift_feature_graphic.svg": (1024, 500),
        }
        for filename, (width, height) in expected.items():
            text = (ROOT / "assets/store" / filename).read_text(encoding="utf-8")
            self.assertRegex(text, rf'width="{width}"')
            self.assertRegex(text, rf'height="{height}"')

    def test_launcher_icon_is_configured_as_application_icon(self):
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn('config/icon="res://assets/store/mindshift_launcher.svg"', project)


if __name__ == "__main__":
    unittest.main()
