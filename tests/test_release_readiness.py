import json
import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]


class ReleaseReadinessTests(unittest.TestCase):
    def test_release_checklist_exists(self):
        self.assertTrue((ROOT / "docs" / "RELEASE_READINESS.md").exists())

    def test_puzzle_library_has_required_metadata(self):
        base = json.loads((ROOT / "data" / "puzzles.json").read_text(encoding="utf-8"))
        extra = json.loads((ROOT / "data" / "puzzles_extra.json").read_text(encoding="utf-8"))
        puzzles = base["puzzles"] + extra["puzzles"]
        self.assertGreaterEqual(len(puzzles), 100)
        for puzzle in puzzles:
            self.assertTrue(puzzle.get("id"))
            self.assertTrue(puzzle.get("prompt"))
            self.assertTrue(puzzle.get("hint"))
            self.assertTrue(puzzle.get("explanation"))
            answer_type = puzzle.get("answer_type", "number" if isinstance(puzzle.get("answer"), (int, float)) else "text")
            self.assertIn(answer_type, {"text", "number", "choice", "true_false"})
            self.assertIn(int(puzzle.get("difficulty", 0)), range(1, 6))

    def test_android_project_is_portrait(self):
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn('handheld/orientation=1', project)
        self.assertIn('size/viewport_width=720', project)
        self.assertIn('size/viewport_height=1280', project)

    def test_mobile_theme_is_configured(self):
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn('theme/custom="res://themes/mindshift_theme.tres"', project)
        theme = ROOT / "themes" / "mindshift_theme.tres"
        self.assertTrue(theme.exists())
        theme_text = theme.read_text(encoding="utf-8")
        for token in ["Button/styles/normal", "Button/styles/hover", "LineEdit/styles/normal", "Panel/styles/panel"]:
            self.assertIn(token, theme_text)


if __name__ == "__main__":
    unittest.main()
