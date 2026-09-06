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


if __name__ == "__main__":
    unittest.main()
