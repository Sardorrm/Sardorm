from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class GameplayRegressionContractTests(unittest.TestCase):
    def test_campaign_solve_wires_stats_progression_and_persistence(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        progression = (ROOT / "src" / "progression_service.gd").read_text(encoding="utf-8")
        self.assertIn("progression.record_attempt(active_puzzle, true", main)
        self.assertIn("_save()", main)
        self.assertIn("stats_manager.record_solved", progression)
        self.assertIn("level_manager.mark_completed", progression)

    def test_failed_answer_consumes_life_and_keeps_retry_path(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        session = (ROOT / "src" / "game_session.gd").read_text(encoding="utf-8")
        self.assertIn("progression.record_attempt(active_puzzle, false", main)
        self.assertIn("lives.lose_life()", main)
        self.assertIn("session.attempts", main)
        self.assertIn("_set_state(STATE_ACTIVE)", session)

    def test_timeout_and_pause_are_part_of_the_runtime_contract(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        session = (ROOT / "src" / "game_session.gd").read_text(encoding="utf-8")
        self.assertIn("session.is_timed_out()", main)
        self.assertIn("session.pause()", main)
        self.assertIn("session.resume()", main)
        self.assertIn("func timeout()", session)
        self.assertIn("timed_out.emit", session)

    def test_daily_and_campaign_paths_do_not_share_level_progression(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        progression = (ROOT / "src" / "progression_service.gd").read_text(encoding="utf-8")
        self.assertIn("not daily_mode", main)
        self.assertIn("mark_campaign_level: bool = true", progression)
        self.assertIn("not daily_mode)", main)

    def test_empty_lives_blocks_start_and_exposes_recovery(self):
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        lives = (ROOT / "src" / "life_manager.gd").read_text(encoding="utf-8")
        self.assertIn("if lives.is_empty():", main)
        self.assertIn("_show_lives_empty()", main)
        self.assertIn("seconds_to_next_life()", main)
        self.assertIn("const RECOVERY_SECONDS := 300", lives)


if __name__ == "__main__":
    unittest.main()
