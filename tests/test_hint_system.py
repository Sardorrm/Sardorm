from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class HintSystemContractTests(unittest.TestCase):
    def test_hint_is_limited_to_one_use_per_session(self):
        code = (ROOT / "src" / "game_session.gd").read_text(encoding="utf-8")
        self.assertIn("var hints_used: int = 0", code)
        self.assertIn("hints_used > 0", code)
        self.assertIn("hints_used = 1", code)

    def test_hint_has_a_score_cost(self):
        code = (ROOT / "src" / "game_rules.gd").read_text(encoding="utf-8")
        self.assertIn("const PASSING_SCORE := 1", code)
        self.assertIn("hint_penalty := 100 if hint_used else 0", code)
        self.assertIn("hint_used", code)

    def test_hint_usage_is_persisted_in_progression_stats(self):
        progression = (ROOT / "src" / "progression_service.gd").read_text(encoding="utf-8")
        stats = (ROOT / "src" / "stats_manager.gd").read_text(encoding="utf-8")
        self.assertIn("stats_manager.record_hint", progression)
        self.assertIn("record_hint", stats)

    def test_hint_is_disabled_while_paused(self):
        code = (ROOT / "src" / "game_session.gd").read_text(encoding="utf-8")
        self.assertIn("or paused", code)
        self.assertIn("func use_hint() -> bool:", code)


if __name__ == "__main__":
    unittest.main()
