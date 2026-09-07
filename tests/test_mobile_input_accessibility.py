from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class MobileInputAccessibilityTests(unittest.TestCase):
    def test_input_factory_supports_all_input_modes(self):
        code = (ROOT / "src" / "answer_input_factory.gd").read_text(encoding="utf-8")
        for token in ["TYPE_TEXT", "TYPE_NUMBER", "TYPE_CHOICE", "TYPE_TRUE_FALSE", "normalize_type", "button_labels"]:
            self.assertIn(token, code)

    def test_gameplay_uses_shared_answer_submission_path(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        self.assertIn('answer.custom_minimum_size = Vector2(0, 64)', main)
        self.assertIn('answer.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER', main)
        self.assertIn('_submit_answer(answer.text, answer, feedback, hint)', main)
        self.assertIn('_submit_answer(value_text, null, feedback, hint)', main)

    def test_ui_polish_keeps_mobile_targets_large_enough(self):
        code = (ROOT / "src" / "ui_polish.gd").read_text(encoding="utf-8")
        self.assertIn("const LEVEL_BUTTON_SIZE := Vector2(76, 64)", code)
        self.assertIn('button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, 58.0)', code)
        self.assertIn('node.custom_minimum_size.y = maxf(node.custom_minimum_size.y, 60.0)', code)


if __name__ == "__main__":
    unittest.main()
