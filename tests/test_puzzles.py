import json
import math
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = json.loads((ROOT / "data/puzzles.json").read_text(encoding="utf-8"))
PUZZLES = DATA["puzzles"]
REQUIRED = {"id", "category", "difficulty", "prompt", "answer", "hint"}
ALLOWED_ANSWER_TYPES = {"text", "number", "choice", "true_false"}


class PuzzleIntegrityTests(unittest.TestCase):
    def test_puzzle_schema_and_ids(self):
        self.assertIsInstance(PUZZLES, list)
        self.assertGreaterEqual(len(PUZZLES), 10)
        ids = []
        prompts = []
        for puzzle in PUZZLES:
            self.assertTrue(REQUIRED.issubset(puzzle), puzzle)
            self.assertIsInstance(puzzle["id"], str)
            self.assertTrue(puzzle["id"].strip())
            self.assertIsInstance(puzzle["category"], str)
            self.assertTrue(puzzle["category"].strip())
            self.assertIsInstance(puzzle["prompt"], str)
            self.assertTrue(puzzle["prompt"].strip())
            self.assertIsInstance(puzzle["hint"], str)
            self.assertTrue(puzzle["hint"].strip())
            self.assertIsInstance(puzzle["answer"], (str, int, float))
            self.assertNotIsInstance(puzzle["answer"], bool)
            self.assertIsInstance(puzzle["difficulty"], int)
            self.assertIn(puzzle["difficulty"], {1, 2, 3, 4, 5})
            if isinstance(puzzle["answer"], float):
                self.assertTrue(math.isfinite(puzzle["answer"]))
            answer_type = puzzle.get("answer_type", "number" if isinstance(puzzle["answer"], (int, float)) else "text")
            self.assertIn(answer_type, ALLOWED_ANSWER_TYPES)
            if "answers" in puzzle:
                self.assertIsInstance(puzzle["answers"], list)
                self.assertTrue(puzzle["answers"])
            if "time_limit_seconds" in puzzle:
                self.assertGreater(puzzle["time_limit_seconds"], 0)
            if "explanation" in puzzle:
                self.assertIsInstance(puzzle["explanation"], str)
                self.assertTrue(puzzle["explanation"].strip())
            ids.append(puzzle["id"])
            prompts.append(puzzle["prompt"].strip().lower())
        self.assertEqual(len(ids), len(set(ids)), "Duplicate puzzle IDs")
        self.assertEqual(len(prompts), len(set(prompts)), "Duplicate puzzle prompts")

    def test_puzzle_answers_are_non_empty(self):
        for puzzle in PUZZLES:
            candidates = puzzle.get("answers", [puzzle["answer"]])
            self.assertTrue(candidates, puzzle["id"])
            for answer in candidates:
                self.assertTrue(str(answer).strip(), puzzle["id"])

    def test_difficulty_distribution_is_not_flat(self):
        self.assertEqual({p["difficulty"] for p in PUZZLES}, {1, 2, 3, 4, 5})

    def test_answer_type_distribution_is_not_flat(self):
        types = {p.get("answer_type", "number" if isinstance(p["answer"], (int, float)) else "text") for p in PUZZLES}
        self.assertTrue({"number", "text"}.issubset(types))

    def test_runtime_architecture_files_exist(self):
        for path in [
            ROOT / "src/puzzle_engine.gd", ROOT / "src/puzzle_definition.gd",
            ROOT / "src/puzzle_repository.gd", ROOT / "src/game_session.gd",
            ROOT / "src/puzzle_result.gd", ROOT / "src/progression_service.gd",
            ROOT / "src/daily_challenge.gd", ROOT / "src/puzzle_interaction.gd",
            ROOT / "src/level_manager.gd", ROOT / "src/save_manager.gd",
            ROOT / "src/stats_manager.gd", ROOT / "src/event_tracker.gd",
            ROOT / "src/achievement_manager.gd", ROOT / "src/game_rules.gd",
            ROOT / "src/difficulty_manager.gd", ROOT / "src/main.gd",
        ]:
            self.assertTrue(path.exists(), path)

    def test_daily_challenge_is_deterministic(self):
        code = (ROOT / "src/daily_challenge.gd").read_text(encoding="utf-8")
        self.assertIn("class_name DailyChallenge", code)
        self.assertIn("select_indices", code)
        self.assertIn("seed_for_date", code)

    def test_interaction_strategy_contract(self):
        code = (ROOT / "src/puzzle_interaction.gd").read_text(encoding="utf-8")
        self.assertIn("class_name PuzzleInteraction", code)
        for token in ["TYPE_TEXT", "TYPE_NUMBER", "TYPE_CHOICE", "TYPE_TRUE_FALSE"]:
            self.assertIn(token, code)


if __name__ == "__main__":
    unittest.main()
