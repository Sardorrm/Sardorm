from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class UIThemeAccessibilityContractTests(unittest.TestCase):
    def test_project_uses_global_mindshift_theme(self):
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn('theme/custom="res://themes/mindshift_theme.tres"', project)

    def test_interactive_buttons_have_mobile_sized_targets_and_keyboard_focus(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        self.assertIn('custom_minimum_size = Vector2(0, maxi(64, height))', main)
        self.assertIn('button.focus_mode = Control.FOCUS_ALL', main)
        self.assertIn('func _button(text: String, callback: Callable, height: int = 64) -> Button:', main)

    def test_level_grid_buttons_have_mobile_sized_targets_and_keyboard_focus(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        self.assertIn('level_button.custom_minimum_size = Vector2(72, 64)', main)
        self.assertIn('level_button.focus_mode = Control.FOCUS_ALL', main)

    def test_text_input_has_mobile_friendly_height_and_numeric_keyboard(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        self.assertIn('answer.custom_minimum_size = Vector2(0, 64)', main)
        self.assertIn('answer.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER', main)

    def test_core_gameplay_buttons_use_the_shared_minimum_target(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        self.assertIn('_button("HINT", func(): _use_hint(hint), 64)', main)
        self.assertIn('pause_button = _button("⏸ PAUZA", _toggle_pause, 64)', main)
        self.assertIn('content.add_child(_button("DARAJALAR" if not daily_mode else "CHALLENGE", _show_levels if not daily_mode else _show_daily, 64))', main)


if __name__ == "__main__":
    unittest.main()
