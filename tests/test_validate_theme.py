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
    def _run_broken_theme(self, replacement, expected_message):
        text = THEME.read_text(encoding="utf-8")
        broken = text.replace(*replacement, 1)
        with tempfile.TemporaryDirectory() as temp_dir:
            candidate = Path(temp_dir) / "mindshift_theme.tres"
            candidate.write_text(broken, encoding="utf-8")
            with self.assertRaisesRegex(SystemExit, expected_message):
                validator.main(candidate)

    def test_validator_accepts_live_theme(self):
        validator.main(THEME)

    def test_validator_rejects_contrast_regression(self):
        self._run_broken_theme(
            (
                "Button/colors/font_disabled_color = Color(0.52, 0.53, 0.62, 1)",
                "Button/colors/font_disabled_color = Color(0.20, 0.20, 0.25, 1)",
            ),
            "disabled control text contrast",
        )

    def test_validator_rejects_missing_focus_resource(self):
        self._run_broken_theme(
            (
                '[sub_resource type="StyleBoxFlat" id="ButtonFocus"]',
                '[sub_resource type="StyleBoxFlat" id="ButtonFocus_REMOVED"]',
            ),
            "premium ButtonFocus style is missing",
        )

    def test_validator_rejects_disabled_input_contrast_regression(self):
        self._run_broken_theme(
            (
                "LineEdit/colors/font_disabled_color = Color(0.52, 0.53, 0.62, 1)",
                "LineEdit/colors/font_disabled_color = Color(0.20, 0.20, 0.25, 1)",
            ),
            "disabled input text contrast",
        )

    def test_validator_rejects_input_focus_contrast_regression(self):
        self._run_broken_theme(
            (
                "[sub_resource type=\"StyleBoxFlat\" id=\"LineEditFocus\"]",
                "[sub_resource type=\"StyleBoxFlat\" id=\"LineEditFocus_REMOVED\"]",
            ),
            "premium LineEditFocus style is missing",
        )


if __name__ == "__main__":
    unittest.main()
