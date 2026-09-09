from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class PuzzleRepositoryHardeningTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.code = (ROOT / "src" / "puzzle_repository.gd").read_text(encoding="utf-8")

    def test_combined_catalog_tracks_normalized_prompt_keys(self):
        self.assertIn("var by_prompt: Dictionary = {}", self.code)
        self.assertIn("by_prompt[_prompt_key(puzzle.prompt)] = puzzle", self.code)
        self.assertIn("Duplicate prompt for ", self.code)

    def test_category_lookup_is_whitespace_and_case_insensitive(self):
        self.assertIn("var normalized := category.strip_edges().to_lower()", self.code)
        self.assertIn("if puzzle.category == normalized:", self.code)

    def test_answers_are_normalized_and_unique_at_runtime(self):
        self.assertIn("str(option).strip_edges().to_lower()", self.code)
        self.assertIn("Duplicate accepted answer for ", self.code)
        self.assertIn("Primary answer must be present in answers for ", self.code)

    def test_true_false_runtime_contract_is_strict(self):
        self.assertIn("normalized_answers.size() != 2", self.code)
        self.assertIn("normalized_answers[0] != \"true\"", self.code)
        self.assertIn("normalized_answers[1] != \"false\"", self.code)

    def test_failed_load_clears_all_indexes(self):
        self.assertIn("by_prompt.clear()", self.code)
        self.assertIn("puzzles.clear()", self.code)
        self.assertIn("by_id.clear()", self.code)

    def test_repository_can_reuse_engine_catalog_without_second_file_parse(self):
        self.assertIn("func load_from_engine(engine: PuzzleEngine) -> bool:", self.code)
        self.assertIn("for raw in engine.puzzles:", self.code)
        self.assertIn("PuzzleDefinition.from_dict(raw)", self.code)

    def test_main_uses_repository_engine_reuse_path(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        self.assertIn("if not repository.load_from_engine(engine):", main)
        self.assertNotIn("if not repository.load_from_file(\"res://data/puzzles.json\"):", main)


if __name__ == "__main__":
    unittest.main()
