from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class UIThemeAccessibilityContractTests(unittest.TestCase):
    def test_project_uses_global_mindshift_theme(self):
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn('theme/custom="res://themes/mindshift_theme.tres"', project)

    def test_interactive_buttons_have_mobile_sized_targets_and_keyboard_focus(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        self.assertIn('custom_minimum_size = Vector2(0, height)', main)
        self.assertIn('button.focus_mode = Control.FOCUS_ALL', main)
        self.assertIn('func _button(text: String, callback: Callable, height: int = 62) -> Button:', main)

    def test_text_input_has_mobile_friendly_height_and_numeric_keyboard(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        self.assertIn('answer.custom_minimum_size = Vector2(0, 64)', main)
        self.assertIn('answer.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER', main)

    def test_touch_targets_are_consistently_at_least_54px_in_core_actions(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        for height in (54, 60, 62, 64, 68, 70):
            self.assertIn(str(height), main)


if __name__ == "__main__":
    unittest.main()
