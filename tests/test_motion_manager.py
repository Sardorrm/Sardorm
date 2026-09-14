import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class MotionManagerContractTests(unittest.TestCase):
    def test_motion_manager_binds_buttons_and_supports_reduced_motion(self):
        code = (ROOT / "src" / "motion_manager.gd").read_text(encoding="utf-8")
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn('const PRESS_SCALE := Vector2(0.98, 0.98)', code)
        self.assertIn('button.button_down.connect', code)
        self.assertIn('button.button_up.connect', code)
        self.assertIn('reduced_motion = bool(data.get("settings", {}).get("reduced_motion", false))', code)
        self.assertIn('MindShiftMotion="*res://src/motion_manager.gd"', project)

    def test_motion_is_lightweight_and_restores_button_scale(self):
        code = (ROOT / "src" / "motion_manager.gd").read_text(encoding="utf-8")
        self.assertIn('button.create_tween()', code)
        self.assertIn('tween.tween_property(button, "scale", Vector2.ONE, PRESS_DURATION)', code)
        self.assertIn('if reduced_motion or not is_instance_valid(button):', code)


if __name__ == "__main__":
    unittest.main()
