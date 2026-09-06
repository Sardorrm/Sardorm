import json
import math
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = json.loads((ROOT / "data/puzzles.json").read_text(encoding="utf-8"))
EXTRA = json.loads((ROOT / "data/puzzles_extra.json").read_text(encoding="utf-8"))
PUZZLES = BASE["puzzles"] + EXTRA["puzzles"]
REQUIRED = {"id", "category", "difficulty", "prompt", "answer", "hint"}
ALLOWED_ANSWER_TYPES = {"text", "number", "choice", "true_false"}


class PuzzleIntegrityTests(unittest.TestCase):
    def test_puzzle_schema_and_ids(self):
        self.assertIsInstance(PUZZLES, list)
        self.assertGreaterEqual(len(PUZZLES), 100)
        ids, prompts = [], []
        for puzzle in PUZZLES:
            self.assertTrue(REQUIRED.issubset(puzzle), puzzle)
            self.assertTrue(isinstance(puzzle["id"], str) and puzzle["id"].strip())
            self.assertTrue(isinstance(puzzle["category"], str) and puzzle["category"].strip())
            self.assertTrue(isinstance(puzzle["prompt"], str) and puzzle["prompt"].strip())
            self.assertTrue(isinstance(puzzle["hint"], str) and puzzle["hint"].strip())
            self.assertIsInstance(puzzle["answer"], (str, int, float))
            self.assertNotIsInstance(puzzle["answer"], bool)
            self.assertIn(puzzle["difficulty"], {1, 2, 3, 4, 5})
            if isinstance(puzzle["answer"], float):
                self.assertTrue(math.isfinite(puzzle["answer"]))
            answer_type = puzzle.get("answer_type", "number" if isinstance(puzzle["answer"], (int, float)) else "text")
            self.assertIn(answer_type, ALLOWED_ANSWER_TYPES)
            if answer_type in {"choice", "true_false"}:
                self.assertIsInstance(puzzle.get("answers"), list)
                self.assertTrue(puzzle["answers"])
            if "answers" in puzzle:
                self.assertIsInstance(puzzle["answers"], list)
                self.assertTrue(puzzle["answers"])
            if "time_limit_seconds" in puzzle:
                self.assertGreater(puzzle["time_limit_seconds"], 0)
            if "explanation" in puzzle:
                self.assertTrue(isinstance(puzzle["explanation"], str) and puzzle["explanation"].strip())
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

    def test_puzzle_explanations_are_reviewed(self):
        banned_fragments = ["not a good puzzle", "ambiguous;", "ambiguous pattern"]
        for puzzle in PUZZLES:
            explanation = puzzle.get("explanation", "").lower()
            self.assertFalse(any(fragment in explanation for fragment in banned_fragments), puzzle["id"])

    def test_choice_and_boolean_options_are_consistent(self):
        for puzzle in PUZZLES:
            answer_type = puzzle.get("answer_type", "number" if isinstance(puzzle["answer"], (int, float)) else "text")
            if answer_type == "choice":
                options = [str(value).strip().lower() for value in puzzle.get("answers", [])]
                self.assertGreaterEqual(len(options), 2, puzzle["id"])
                self.assertEqual(len(options), len(set(options)), puzzle["id"])
                self.assertIn(str(puzzle["answer"]).strip().lower(), options, puzzle["id"])
            if answer_type == "true_false":
                options = [str(value).strip().lower() for value in puzzle.get("answers", [])]
                self.assertEqual(options, ["true", "false"], puzzle["id"])
                self.assertIn(str(puzzle["answer"]).strip().lower(), options, puzzle["id"])

    def test_difficulty_distribution_is_not_flat(self):
        self.assertEqual({p["difficulty"] for p in PUZZLES}, {1, 2, 3, 4, 5})
        self.assertGreaterEqual(sum(p["difficulty"] == 5 for p in PUZZLES), 10)

    def test_answer_type_distribution_is_not_flat(self):
        types = {p.get("answer_type", "number" if isinstance(p["answer"], (int, float)) else "text") for p in PUZZLES}
        self.assertTrue({"number", "text", "choice", "true_false"}.issubset(types))

    def test_runtime_architecture_files_exist(self):
        for path in [
            ROOT / "src/puzzle_engine.gd", ROOT / "src/puzzle_definition.gd",
            ROOT / "src/puzzle_repository.gd", ROOT / "src/game_session.gd",
            ROOT / "src/puzzle_result.gd", ROOT / "src/progression_service.gd",
            ROOT / "src/daily_challenge.gd", ROOT / "src/daily_challenge_service.gd",
            ROOT / "src/puzzle_interaction.gd", ROOT / "src/answer_input_factory.gd",
            ROOT / "src/level_manager.gd", ROOT / "src/save_manager.gd",
            ROOT / "src/stats_manager.gd", ROOT / "src/life_manager.gd",
            ROOT / "src/streak_manager.gd", ROOT / "src/event_tracker.gd",
            ROOT / "src/achievement_manager.gd", ROOT / "src/game_rules.gd",
            ROOT / "src/difficulty_manager.gd", ROOT / "src/main.gd",
        ]:
            self.assertTrue(path.exists(), path)

    def test_daily_challenge_contract(self):
        code = (ROOT / "src/daily_challenge.gd").read_text(encoding="utf-8")
        service = (ROOT / "src/daily_challenge_service.gd").read_text(encoding="utf-8")
        for token in ["class_name DailyChallenge", "select_indices", "seed_for_date"]:
            self.assertIn(token, code)
        for token in ["current_position", "record_solved", "record_failed", "is_session_completed"]:
            self.assertIn(token, service)

    def test_interaction_strategy_contract(self):
        code = (ROOT / "src/puzzle_interaction.gd").read_text(encoding="utf-8")
        self.assertIn("class_name PuzzleInteraction", code)
        for token in ["TYPE_TEXT", "TYPE_NUMBER", "TYPE_CHOICE", "TYPE_TRUE_FALSE"]:
            self.assertIn(token, code)

    def test_answer_input_factory_contract(self):
        code = (ROOT / "src/answer_input_factory.gd").read_text(encoding="utf-8")
        self.assertIn("class_name AnswerInputFactory", code)
        for token in ["normalize_type", "button_labels", "validate"]:
            self.assertIn(token, code)

    def test_progression_does_not_force_daily_campaign_unlocks(self):
        code = (ROOT / "src/progression_service.gd").read_text(encoding="utf-8")
        self.assertIn("mark_campaign_level", code)
        self.assertIn("if mark_campaign_level and level_manager != null", code)

    def test_stats_track_attempt_time(self):
        code = (ROOT / "src/stats_manager.gd").read_text(encoding="utf-8")
        for token in ["attempt_counted_time_seconds", "record_failed", "get_average_time"]:
            self.assertIn(token, code)

    def test_difficulty_and_streak_contracts(self):
        difficulty = (ROOT / "src/difficulty_manager.gd").read_text(encoding="utf-8")
        streak = (ROOT / "src/streak_manager.gd").read_text(encoding="utf-8")
        self.assertIn("score_multiplier", difficulty)
        for token in ["record_daily_completion", "get_multiplier", "best_streak"]:
            self.assertIn(token, streak)


if __name__ == "__main__":
    unittest.main()
