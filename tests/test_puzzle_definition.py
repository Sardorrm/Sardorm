from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class PuzzleDefinitionNormalizationTests(unittest.TestCase):
    def test_source_validation_is_not_weakened_by_clamping(self):
        code = (ROOT / "src" / "puzzle_definition.gd").read_text(encoding="utf-8")
        self.assertIn("puzzle.difficulty = int(data.get(\"difficulty\", 0))", code)
        self.assertNotIn("puzzle.difficulty = clampi(int(data.get(\"difficulty\", 1)), 1, 5)", code)

    def test_textual_catalog_fields_are_normalized(self):
        code = (ROOT / "src" / "puzzle_definition.gd").read_text(encoding="utf-8")
        self.assertIn("puzzle.id = str(data.get(\"id\", \"\")).strip_edges()", code)
        self.assertIn("puzzle.category = str(data.get(\"category\", \"\")).strip_edges().to_lower()", code)
        self.assertIn("puzzle.answer_type = str(data.get(\"answer_type\", _infer_answer_type(puzzle.answer))).strip_edges().to_lower()", code)

    def test_runtime_validator_still_rejects_invalid_difficulty(self):
        code = (ROOT / "src" / "puzzle_repository.gd").read_text(encoding="utf-8")
        self.assertIn("if puzzle.difficulty < 1 or puzzle.difficulty > 5:", code)
        self.assertIn("Difficulty must be 1..5 for ", code)


if __name__ == "__main__":
    unittest.main()
