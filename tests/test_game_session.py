import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]


class GameSessionContractTests(unittest.TestCase):
    def test_pause_resume_contract(self):
        code = (ROOT / "src" / "game_session.gd").read_text(encoding="utf-8")
        for token in ["var paused := false", "func pause()", "func resume()", "paused_total_msec", "if state != STATE_ACTIVE or puzzle == null or paused"]:
            self.assertIn(token, code)

    def test_pause_preserves_timeout_budget(self):
        code = (ROOT / "src" / "game_session.gd").read_text(encoding="utf-8")
        self.assertIn("effective_now := paused_at_msec if paused else Time.get_ticks_msec()", code)
        self.assertIn("- paused_total_msec", code)

    def test_pause_resume_ui_wiring(self):
        code = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        self.assertIn("var pause_button: Button", code)
        self.assertIn('"⏸ PAUZA"', code)
        self.assertIn('"▶ DAVOM ETISH"', code)
        self.assertIn("func _toggle_pause()", code)
        self.assertIn("session.pause()", code)
        self.assertIn("session.resume()", code)
        self.assertIn("timer_tick.stop()", code)
        self.assertIn("timer_tick.start()", code)

    def test_timeout_ui_uses_existing_session_contract(self):
        session = (ROOT / "src" / "game_session.gd").read_text(encoding="utf-8")
        main = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        self.assertIn("func check_timeout() -> bool:", session)
        self.assertIn("if session.check_timeout():", main)
        self.assertNotIn("session.is_timed_out()", main)
        self.assertIn('"QAYTA URINISH"', main)
        self.assertIn("func _retry_current_puzzle()", main)


if __name__ == "__main__":
    unittest.main()
