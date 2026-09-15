import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
THEME = ROOT / "themes" / "mindshift_theme.tres"


class PremiumThemeControlsTests(unittest.TestCase):
    def setUp(self):
        self.text = THEME.read_text(encoding="utf-8")

    def test_primary_controls_share_accessible_typography(self):
        for control in ("Button", "OptionButton", "CheckButton"):
            self.assertIn(f"{control}/font_sizes/font_size = 19", self.text)
            self.assertIn(
                f"{control}/colors/font_disabled_color = Color(0.40, 0.41, 0.50, 1)",
                self.text,
            )

    def test_primary_controls_share_state_surfaces(self):
        for control in ("Button", "OptionButton", "CheckButton"):
            for state in ("normal", "hover", "pressed", "disabled"):
                self.assertIn(
                    f'{control}/styles/{state} = SubResource("Button{state.capitalize()}")',
                    self.text,
                )

    def test_text_input_and_label_remain_readable(self):
        self.assertIn("LineEdit/font_sizes/font_size = 20", self.text)
        self.assertIn("Label/font_sizes/font_size = 18", self.text)
        self.assertIn("LineEdit/styles/focus = SubResource(\"LineEditFocus\")", self.text)

    def test_button_state_styles_keep_premium_shape_tokens(self):
        self.assertIn("Button/styles/normal = SubResource(\"ButtonNormal\")", self.text)
        self.assertIn("Button/styles/hover = SubResource(\"ButtonHover\")", self.text)
        self.assertIn("Button/styles/pressed = SubResource(\"ButtonPressed\")", self.text)
        self.assertIn("corner_radius_top_left = 16", self.text)
        self.assertIn("corner_radius_bottom_left = 16", self.text)


if __name__ == "__main__":
    unittest.main()
