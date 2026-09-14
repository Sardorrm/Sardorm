import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class SafeAreaManagerContractTests(unittest.TestCase):
    def test_safe_area_manager_is_wired_and_reacts_to_viewport_changes(self):
        code = (ROOT / "src" / "safe_area_manager.gd").read_text(encoding="utf-8")
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn("DisplayServer.get_display_safe_area()", code)
        self.assertIn('get_viewport().size_changed.connect(_queue_refresh)', code)
        self.assertIn('find_child("SafeAreaShell", true, false)', code)
        self.assertIn('MindShiftSafeArea="*res://src/safe_area_manager.gd"', project)

    def test_margins_have_mobile_safe_minimum_and_safe_insets(self):
        code = (ROOT / "src" / "safe_area_manager.gd").read_text(encoding="utf-8")
        self.assertIn("const MIN_MARGIN := 20", code)
        self.assertIn("left + CONTENT_GAP", code)
        self.assertIn("top + CONTENT_GAP", code)
        self.assertIn("right + CONTENT_GAP", code)
        self.assertIn("bottom + CONTENT_GAP", code)

    def test_refresh_is_debounced_for_bursty_tree_changes(self):
        code = (ROOT / "src" / "safe_area_manager.gd").read_text(encoding="utf-8")
        self.assertIn("var _refresh_pending := false", code)
        self.assertIn("func _queue_refresh() -> void:", code)
        self.assertIn("if _refresh_pending:", code)
        self.assertIn("_refresh_pending = true", code)
        self.assertIn('call_deferred("_refresh")', code)


if __name__ == "__main__":
    unittest.main()
