import json
import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]


class ReleaseReadinessTests(unittest.TestCase):
    def test_release_checklist_exists(self):
        self.assertTrue((ROOT / "docs" / "RELEASE_READINESS.md").exists())

    def test_puzzle_library_has_required_metadata(self):
        data = json.loads((ROOT / "data" / "puzzles.json").read_text(encoding="utf-8"))
        puzzles = data["puzzles"]
        self.assertGreaterEqual(len(puzzles), 35)
        for puzzle in puzzles:
            self.assertTrue(puzzle.get("id"))
            self.assertTrue(puzzle.get("prompt"))
            self.assertTrue(puzzle.get("explanation"))
            self.assertIn(puzzle.get("answer_type"), {"text", "number", "choice", "true_false"})
            self.assertIn(int(puzzle.get("difficulty", 0)), range(1, 6))
            self.assertTrue(puzzle.get("tags"))

    def test_android_project_is_portrait(self):
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn('display/window/handheld/orientation=1', project)
        self.assertIn('display/window/size/viewport_width=720', project)
        self.assertIn('display/window/size/viewport_height=1280', project)


if __name__ == "__main__":
    unittest.main()
