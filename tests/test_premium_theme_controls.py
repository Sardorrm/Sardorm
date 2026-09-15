import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
THEME = ROOT / "themes" / "mindshift_theme.tres"


def _relative_luminance(rgb):
    channels = [channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4 for channel in rgb]
    return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]


def _contrast_ratio(foreground, background):
    foreground_l = _relative_luminance(foreground)
    background_l = _relative_luminance(background)
    light, dark = max(foreground_l, background_l), min(foreground_l, background_l)
    return (light + 0.05) / (dark + 0.05)


class PremiumThemeControlsTests(unittest.TestCase):
    def setUp(self):
        self.text = THEME.read_text(encoding="utf-8")

    def test_theme_resource_load_contract(self):
        self.assertIn('[gd_resource type="Theme" load_steps=9 format=3]', self.text)

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

    def test_primary_controls_share_keyboard_focus_surface(self):
        for control in ("Button", "OptionButton", "CheckButton"):
            self.assertIn(
                f'{control}/styles/focus = SubResource("ButtonFocus")',
                self.text,
            )
        self.assertIn("border_color = Color(0.70, 0.72, 1, 1)", self.text)
        self.assertIn("expand_margin_left = 2.0", self.text)

    def test_text_input_and_label_remain_readable(self):
        self.assertIn("LineEdit/font_sizes/font_size = 20", self.text)
        self.assertIn("Label/font_sizes/font_size = 18", self.text)
        self.assertIn("LineEdit/styles/focus = SubResource(\"LineEditFocus\")", self.text)

    def test_wcag_informed_contrast_floor(self):
        self.assertGreaterEqual(
            _contrast_ratio((0.40, 0.41, 0.50), (0.07, 0.07, 0.10)),
            3.0,
        )
        self.assertGreaterEqual(
            _contrast_ratio((0.48, 0.49, 0.58), (0.08, 0.08, 0.12)),
            4.5,
        )
        self.assertGreaterEqual(
            _contrast_ratio((0.93, 0.93, 0.98), (0.055, 0.058, 0.09)),
            4.5,
        )
        self.assertGreaterEqual(
            _contrast_ratio((0.70, 0.72, 1.0), (0.12, 0.12, 0.19)),
            3.0,
        )

    def test_button_state_styles_keep_premium_shape_tokens(self):
        self.assertIn("Button/styles/normal = SubResource(\"ButtonNormal\")", self.text)
        self.assertIn("Button/styles/hover = SubResource(\"ButtonHover\")", self.text)
        self.assertIn("Button/styles/pressed = SubResource(\"ButtonPressed\")", self.text)
        self.assertIn("corner_radius_top_left = 16", self.text)
        self.assertIn("corner_radius_bottom_left = 16", self.text)


if __name__ == "__main__":
    unittest.main()
