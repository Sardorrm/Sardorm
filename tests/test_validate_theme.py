import importlib.util
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
THEME = ROOT / "themes" / "mindshift_theme.tres"
VALIDATOR_PATH = ROOT / "scripts" / "validate_theme.py"


spec = importlib.util.spec_from_file_location("validate_theme", VALIDATOR_PATH)
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)


class PremiumThemeValidatorTests(unittest.TestCase):
    def test_validator_accepts_live_theme(self):
        validator.main(THEME)

    def test_validator_rejects_contrast_regression(self):
        text = THEME.read_text(encoding="utf-8")
        broken = text.replace(
            "Button/colors/font_disabled_color = Color(0.52, 0.53, 0.62, 1)",
            "Button/colors/font_disabled_color = Color(0.20, 0.20, 0.25, 1)",
            1,
        )
        with tempfile.TemporaryDirectory() as temp_dir:
            candidate = Path(temp_dir) / "mindshift_theme.tres"
            candidate.write_text(broken, encoding="utf-8")
            with self.assertRaisesRegex(SystemExit, "disabled control text contrast"):
                validator.main(candidate)


if __name__ == "__main__":
    unittest.main()
