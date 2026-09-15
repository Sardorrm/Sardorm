import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
THEME = ROOT / "themes" / "mindshift_theme.tres"


class PremiumThemeContractTests(unittest.TestCase):
    def setUp(self):
        self.text = THEME.read_text(encoding="utf-8")

    def test_focus_styles_cover_interactive_controls(self):
        for control in ("Button", "OptionButton", "CheckButton"):
            self.assertIn(
                f'{control}/styles/focus = SubResource("ButtonFocus")',
                self.text,
            )
        self.assertIn('LineEdit/styles/focus = SubResource("LineEditFocus")', self.text)

    def test_primary_controls_keep_consistent_premium_radius(self):
        radius_tokens = (
            "corner_radius_top_left = 16",
            "corner_radius_top_right = 16",
            "corner_radius_bottom_right = 16",
            "corner_radius_bottom_left = 16",
        )
        for token in radius_tokens:
            self.assertGreaterEqual(self.text.count(token), 5)

    def test_accessibility_tokens_remain_explicit(self):
        self.assertIn("border_color = Color(0.70, 0.72, 1, 1)", self.text)
        self.assertIn("Button/colors/font_disabled_color = Color(0.40, 0.41, 0.50, 1)", self.text)
        self.assertIn("OptionButton/colors/font_disabled_color = Color(0.40, 0.41, 0.50, 1)", self.text)
        self.assertIn("CheckButton/colors/font_disabled_color = Color(0.40, 0.41, 0.50, 1)", self.text)

    def test_text_input_contract_stays_premium_and_readable(self):
        self.assertIn("LineEdit/font_sizes/font_size = 20", self.text)
        self.assertIn("LineEdit/colors/font_placeholder_color = Color(0.48, 0.49, 0.58, 1)", self.text)
        self.assertIn("Label/font_sizes/font_size = 18", self.text)


if __name__ == "__main__":
    unittest.main()
