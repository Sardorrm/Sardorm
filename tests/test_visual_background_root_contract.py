from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class VisualBackgroundRootContractTests(unittest.TestCase):
    def test_manager_supports_dynamic_unnamed_control_shell(self):
        code = (ROOT / "src" / "visual_backgrounds.gd").read_text(encoding="utf-8")
        self.assertIn("var ui: Control = null", code)
        self.assertIn("for child in scene.get_children():", code)
        self.assertIn("if child is Control:", code)
        self.assertIn("ui = child as Control", code)
        self.assertIn('ui = scene.find_child("Control", true, false) as Control', code)

    def test_background_remains_full_rect_and_noninteractive(self):
        code = (ROOT / "src" / "visual_backgrounds.gd").read_text(encoding="utf-8")
        self.assertIn("background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)", code)
        self.assertIn("background.mouse_filter = Control.MOUSE_FILTER_IGNORE", code)
        self.assertIn("background.z_index = -10", code)


if __name__ == "__main__":
    unittest.main()
