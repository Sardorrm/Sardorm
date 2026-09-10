from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class LargeCatalogPerformanceContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.code = (ROOT / "src" / "puzzle_engine.gd").read_text(encoding="utf-8")

    def test_category_index_uses_constant_time_seen_lookup(self):
        self.assertIn("var seen: Dictionary = {}", self.code)
        self.assertIn("not seen.has(category)", self.code)
        self.assertIn("seen[category] = true", self.code)

    def test_category_lookup_does_not_scan_result_array_per_puzzle(self):
        self.assertNotIn("not result.has(category)", self.code)

    def test_large_catalog_path_keeps_single_pass_category_indexing(self):
        category_block = self.code.split("func get_categories() -> Array:", 1)[1].split("func check_answer", 1)[0]
        self.assertEqual(category_block.count("for puzzle in puzzles:"), 1)
        self.assertEqual(category_block.count("seen.has(category)"), 1)


if __name__ == "__main__":
    unittest.main()
