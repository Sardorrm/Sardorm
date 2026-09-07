from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class AnswerInputFactoryContractTests(unittest.TestCase):
    def test_supported_types_and_safe_fallback(self):
        code = (ROOT / "src" / "answer_input_factory.gd").read_text(encoding="utf-8")
        for token in [
            'const TYPE_TEXT := "text"',
            'const TYPE_NUMBER := "number"',
            'const TYPE_CHOICE := "choice"',
            'const TYPE_TRUE_FALSE := "true_false"',
            'return TYPE_TEXT',
        ]:
            self.assertIn(token, code)

    def test_numeric_and_button_modes_are_explicit(self):
        code = (ROOT / "src" / "answer_input_factory.gd").read_text(encoding="utf-8")
        self.assertIn('return kind == TYPE_CHOICE or kind == TYPE_TRUE_FALSE', code)
        self.assertIn('return normalize_type(puzzle) == TYPE_NUMBER', code)
        self.assertIn('return ["To‘g‘ri", "Noto‘g‘ri"]', code)

    def test_validation_delegates_to_single_interaction_contract(self):
        code = (ROOT / "src" / "answer_input_factory.gd").read_text(encoding="utf-8")
        self.assertIn('return PuzzleInteraction.validate_selection(puzzle, value)', code)

    def test_interaction_normalizes_true_false_aliases(self):
        code = (ROOT / "src" / "puzzle_interaction.gd").read_text(encoding="utf-8")
        for token in [
            '"to‘g‘ri", "to\'g\'ri", "togri", "true", "1"',
            '"noto‘g‘ri", "noto\'g\'ri", "notogri", "false", "0"',
        ]:
            self.assertIn(token, code)
        self.assertIn('value.strip_edges().to_lower()', code)


if __name__ == "__main__":
    unittest.main()
