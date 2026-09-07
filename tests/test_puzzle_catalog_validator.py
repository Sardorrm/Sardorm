import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class PuzzleCatalogValidatorTests(unittest.TestCase):
    def test_validator_covers_both_runtime_packs(self):
        code = (ROOT / "scripts/validate_puzzles.py").read_text(encoding="utf-8")
        self.assertIn('PACK_PATHS = (ROOT / "data" / "puzzles.json", ROOT / "data" / "puzzles_extra.json")', code)
        self.assertIn("combined catalog: duplicate id", code)
        self.assertIn("combined catalog: duplicate prompt", code)

    def test_runtime_packs_are_json_and_have_distinct_ids(self):
        base = json.loads((ROOT / "data/puzzles.json").read_text(encoding="utf-8"))
        extra = json.loads((ROOT / "data/puzzles_extra.json").read_text(encoding="utf-8"))
        base_ids = {p["id"] for p in base["puzzles"]}
        extra_ids = {p["id"] for p in extra["puzzles"]}
        self.assertTrue(base_ids)
        self.assertTrue(extra_ids)
        self.assertTrue(base_ids.isdisjoint(extra_ids))

    def test_catalog_has_release_minimums(self):
        base = json.loads((ROOT / "data/puzzles.json").read_text(encoding="utf-8"))
        extra = json.loads((ROOT / "data/puzzles_extra.json").read_text(encoding="utf-8"))
        puzzles = base["puzzles"] + extra["puzzles"]
        self.assertGreaterEqual(len(puzzles), 100)
        self.assertGreaterEqual(sum(p["difficulty"] == 5 for p in puzzles), 10)
        self.assertTrue({"choice", "true_false"}.issubset({p.get("answer_type") for p in puzzles}))


if __name__ == "__main__":
    unittest.main()
