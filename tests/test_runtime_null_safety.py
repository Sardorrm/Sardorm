import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]


class RuntimeNullSafetyTests(unittest.TestCase):
    def test_level_manager_setup_guards_missing_engine(self):
        code = (ROOT / "src" / "level_manager.gd").read_text(encoding="utf-8")
        self.assertIn("puzzle_engine = engine", code)
        self.assertIn("if puzzle_engine == null:", code)
        self.assertIn("completed_levels = []", code)
        self.assertIn("current_level = 0", code)
        self.assertIn("return", code)

    def test_level_manager_sanitize_guards_missing_engine(self):
        code = (ROOT / "src" / "level_manager.gd").read_text(encoding="utf-8")
        self.assertIn("if puzzle_engine == null or typeof(value) != TYPE_ARRAY:", code)
        self.assertIn("return []", code)

    def test_level_queries_remain_safe_without_engine(self):
        code = (ROOT / "src" / "level_manager.gd").read_text(encoding="utf-8")
        self.assertIn("return 0 if puzzle_engine == null else puzzle_engine.puzzles.size()", code)
        self.assertIn("if index < 0 or index >= get_level_count():", code)


if __name__ == "__main__":
    unittest.main()
