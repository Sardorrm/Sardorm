from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class SafeAreaContractTests(unittest.TestCase):
    def test_ui_polish_reads_platform_safe_area(self):
        code = (ROOT / "src" / "ui_polish.gd").read_text(encoding="utf-8")
        self.assertIn('DisplayServer.get_display_safe_area()', code)
        self.assertIn('DisplayServer.screen_get_size(DisplayServer.SCREEN_OF_MAIN_WINDOW)', code)
        self.assertIn('OS.has_feature("android") or OS.has_feature("ios")', code)

    def test_safe_area_is_applied_to_all_portrait_margins(self):
        code = (ROOT / "src" / "ui_polish.gd").read_text(encoding="utf-8")
        self.assertIn('var margins := calculate_safe_margins(', code)
        self.assertIn('"margin_left", roundi(margins.x)', code)
        self.assertIn('"margin_right", roundi(margins.y)', code)
        self.assertIn('"margin_top", roundi(margins.z)', code)
        self.assertIn('"margin_bottom", roundi(margins.w)', code)
        self.assertIn('safe.position.x', code)
        self.assertIn('screen_size.x - safe.end.x', code)
        self.assertIn('screen_size.y - safe.end.y', code)

    def test_platform_guard_keeps_desktop_layout_stable(self):
        code = (ROOT / "src" / "ui_polish.gd").read_text(encoding="utf-8")
        self.assertIn('calculate_safe_margins(ui_size: Vector2, screen_size: Vector2, safe: Rect2, mobile: bool)', code)
        self.assertIn('if mobile and safe.size.x > 0', code)
        self.assertIn('const BASE_MARGIN_LEFT := 24.0', code)
        self.assertIn('const BASE_MARGIN_RIGHT := 24.0', code)
        self.assertIn('const BASE_MARGIN_TOP := 28.0', code)
        self.assertIn('const BASE_MARGIN_BOTTOM := 28.0', code)


if __name__ == "__main__":
    unittest.main()
