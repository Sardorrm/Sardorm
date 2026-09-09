from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


class TypographyReadabilityContractTests(unittest.TestCase):
    def test_theme_defines_readable_label_defaults(self):
        theme = (ROOT / "themes" / "mindshift_theme.tres").read_text(encoding="utf-8")
        self.assertIn('Label/colors/font_color = Color(0.93, 0.93, 0.98, 1)', theme)
        self.assertIn('Label/font_sizes/font_size = 18', theme)

    def test_core_text_has_explicit_readability_sizes(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        sizes = [int(value) for value in re.findall(r'_label\([^\n]*?,\s*(\d+)\)', main)]
        self.assertTrue(sizes)
        self.assertGreaterEqual(min(sizes), 15)
        self.assertIn('active_puzzle.prompt, 25', main)

    def test_interactive_controls_keep_focusable_large_text(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        self.assertIn('button.add_theme_font_size_override("font_size", 20)', main)
        self.assertIn('answer.add_theme_font_size_override("font_size", 21)', main)
        self.assertIn('button.focus_mode = Control.FOCUS_ALL', main)


if __name__ == "__main__":
    unittest.main()
