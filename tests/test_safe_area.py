from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class SafeAreaContractTests(unittest.TestCase):
    def test_ui_polish_reads_platform_safe_area(self):
        code = (ROOT / "src" / "ui_polish.gd").read_text(encoding="utf-8")
        self.assertIn('DisplayServer.get_display_safe_area()', code)
        self.assertIn('DisplayServer.screen_get_size(DisplayServer.SCREEN_OF_MAIN_WINDOW)', code)

    def test_safe_area_is_applied_to_all_portrait_margins(self):
        code = (ROOT / "src" / "ui_polish.gd").read_text(encoding="utf-8")
        self.assertIn('"margin_left", roundi(left)', code)
        self.assertIn('"margin_right", roundi(right)', code)
        self.assertIn('"margin_top", roundi(top)', code)
        self.assertIn('"margin_bottom", roundi(bottom)', code)

    def test_platform_guard_keeps_desktop_layout_stable(self):
        code = (ROOT / "src" / "ui_polish.gd").read_text(encoding="utf-8")
        self.assertIn('if OS.has_feature("android") or OS.has_feature("ios"):', code)
        self.assertIn('const BASE_MARGIN_LEFT := 24.0', code)
        self.assertIn('const BASE_MARGIN_TOP := 28.0', code)


if __name__ == "__main__":
    unittest.main()
