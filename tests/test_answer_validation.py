import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class AnswerValidationContractTests(unittest.TestCase):
    def test_localized_true_false_normalization(self):
        code = (ROOT / "src" / "puzzle_interaction.gd").read_text(encoding="utf-8")
        for token in ["to‘g‘ri", "to'g'ri", "togri", "noto‘g‘ri", "noto'g'ri", "notogri"]:
            self.assertIn(token, code)
        self.assertIn("TYPE_TRUE_FALSE", code)

    def test_game_session_uses_shared_validator(self):
        code = (ROOT / "src" / "game_session.gd").read_text(encoding="utf-8")
        self.assertIn("return PuzzleInteraction.validate_selection(puzzle, value)", code)
        self.assertNotIn("func _normalize(value: String)", code)


if __name__ == "__main__":
    unittest.main()
