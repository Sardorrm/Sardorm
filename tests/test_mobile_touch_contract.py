from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "src" / "main.gd"


class MobileTouchContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.source = MAIN.read_text(encoding="utf-8")

    def test_shared_button_factory_clamps_requested_height(self):
        self.assertIn("func _button(text: String, callback: Callable, height: int = 64) -> Button:", self.source)
        self.assertIn("button.custom_minimum_size = Vector2(0, maxi(64, height))", self.source)
        self.assertIn("button.focus_mode = Control.FOCUS_ALL", self.source)

    def test_settings_controls_cannot_render_below_mobile_target(self):
        settings_calls = (
            'content.add_child(_button(sound_text, _toggle_sound, 60))',
            'content.add_child(_button(haptics_text, _toggle_haptics, 60))',
            'content.add_child(_button("PROGRESSNI TOZALASH", _reset_progress, 60))',
        )
        for call in settings_calls:
            self.assertIn(call, self.source)
        self.assertGreaterEqual(self.source.count("maxi(64, height)"), 1)

    def test_level_grid_keeps_touch_target_and_keyboard_focus(self):
        self.assertIn("level_button.custom_minimum_size = Vector2(72, 64)", self.source)
        self.assertIn("level_button.focus_mode = Control.FOCUS_ALL", self.source)

    def test_text_input_keeps_mobile_height_and_virtual_keyboard(self):
        self.assertIn("answer.custom_minimum_size = Vector2(0, 64)", self.source)
        self.assertIn("answer.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER", self.source)
        self.assertIn("answer.grab_focus()", self.source)


if __name__ == "__main__":
    unittest.main()
