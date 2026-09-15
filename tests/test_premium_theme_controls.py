import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
THEME = ROOT / "themes" / "mindshift_theme.tres"
COLOR_RE = re.compile(
    r"(?P<key>[A-Za-z]+(?:/[A-Za-z]+)*) = Color\((?P<values>[^)]+)\)"
)


def _relative_luminance(rgb):
    channels = [channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4 for channel in rgb]
    return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]


def _contrast_ratio(foreground, background):
    foreground_l = _relative_luminance(foreground)
    background_l = _relative_luminance(background)
    light, dark = max(foreground_l, background_l), min(foreground_l, background_l)
    return (light + 0.05) / (dark + 0.05)


def _theme_color(text, key):
    match = next(
        (match for match in COLOR_RE.finditer(text) if match.group("key") == key),
        None,
    )
    if match is None:
        raise AssertionError(f"Missing theme color: {key}")
    values = [float(value.strip()) for value in match.group("values").split(",")]
    if len(values) != 4:
        raise AssertionError(f"Expected RGBA for {key}, got {values}")
    return tuple(values[:3])


class PremiumThemeControlsTests(unittest.TestCase):
    def setUp(self):
        self.text = THEME.read_text(encoding="utf-8")

    def test_theme_resource_load_contract(self):
        self.assertIn('[gd_resource type="Theme" load_steps=9 format=3]', self.text)

    def test_primary_controls_share_accessible_typography(self):
        for control in ("Button", "OptionButton", "CheckButton"):
            self.assertIn(f"{control}/font_sizes/font_size = 19", self.text)
            self.assertIn(
                f"{control}/colors/font_disabled_color = Color(0.52, 0.53, 0.62, 1)",
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

    def test_wcag_informed_contrast_floor_uses_live_theme_tokens(self):
        disabled_text = _theme_color(self.text, "Button/colors/font_disabled_color")
        disabled_bg = _theme_color(self.text, "ButtonDisabled/bg_color")
        placeholder = _theme_color(self.text, "LineEdit/colors/font_placeholder_color")
        input_bg = _theme_color(self.text, "LineEditNormal/bg_color")
        label = _theme_color(self.text, "Label/colors/font_color")
        panel_bg = _theme_color(self.text, "Panel/bg_color")
        focus = _theme_color(self.text, "ButtonFocus/border_color")
        focus_bg = _theme_color(self.text, "ButtonFocus/bg_color")

        self.assertGreaterEqual(_contrast_ratio(disabled_text, disabled_bg), 4.5)
        self.assertGreaterEqual(_contrast_ratio(placeholder, input_bg), 4.5)
        self.assertGreaterEqual(_contrast_ratio(label, panel_bg), 4.5)
        self.assertGreaterEqual(_contrast_ratio(focus, focus_bg), 3.0)

    def test_button_state_styles_keep_premium_shape_tokens(self):
        self.assertIn("Button/styles/normal = SubResource(\"ButtonNormal\")", self.text)
        self.assertIn("Button/styles/hover = SubResource(\"ButtonHover\")", self.text)
        self.assertIn("Button/styles/pressed = SubResource(\"ButtonPressed\")", self.text)
        self.assertIn("corner_radius_top_left = 16", self.text)
        self.assertIn("corner_radius_bottom_left = 16", self.text)


if __name__ == "__main__":
    unittest.main()
