from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class PuzzleInteractionContractTests(unittest.TestCase):
    def test_supported_input_types_and_null_safety(self):
        code = (ROOT / "src" / "puzzle_interaction.gd").read_text(encoding="utf-8")
        for token in [
            'const TYPE_TEXT := "text"',
            'const TYPE_NUMBER := "number"',
            'const TYPE_CHOICE := "choice"',
            'const TYPE_TRUE_FALSE := "true_false"',
            'if puzzle == null:',
            'return false',
        ]:
            self.assertIn(token, code)

    def test_numeric_answers_are_normalized_consistently(self):
        code = (ROOT / "src" / "puzzle_interaction.gd").read_text(encoding="utf-8")
        self.assertIn('if input_type(puzzle) == TYPE_NUMBER:', code)
        self.assertIn('selected.is_valid_float()', code)
        self.assertIn('return "%0.12f" % numeric', code)

    def test_true_false_aliases_are_supported(self):
        code = (ROOT / "src" / "puzzle_interaction.gd").read_text(encoding="utf-8")
        self.assertIn('["to‘g‘ri", "to\'g\'ri", "togri", "true", "1"]', code)
        self.assertIn('["noto‘g‘ri", "noto\'g\'ri", "notogri", "false", "0"]', code)

    def test_answer_factory_delegates_to_shared_validation(self):
        code = (ROOT / "src" / "answer_input_factory.gd").read_text(encoding="utf-8")
        self.assertIn('return PuzzleInteraction.validate_selection(puzzle, value)', code)


if __name__ == "__main__":
    unittest.main()
