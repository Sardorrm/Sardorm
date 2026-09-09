from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class AppLifecycleContractTests(unittest.TestCase):
    def test_app_lifecycle_is_registered_as_autoload(self):
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn('MindShiftAppLifecycle="*res://src/app_lifecycle.gd"', project)

    def test_mobile_pause_and_resume_notifications_are_handled(self):
        lifecycle = (ROOT / "src" / "app_lifecycle.gd").read_text(encoding="utf-8")
        self.assertIn("NOTIFICATION_APPLICATION_PAUSED", lifecycle)
        self.assertIn("NOTIFICATION_APPLICATION_RESUMED", lifecycle)
        self.assertIn("_pause_active_game()", lifecycle)
        self.assertIn("_resume_active_game()", lifecycle)

    def test_background_pause_only_affects_an_active_unpaused_session(self):
        lifecycle = (ROOT / "src" / "app_lifecycle.gd").read_text(encoding="utf-8")
        self.assertIn("session.state == GameSession.STATE_ACTIVE", lifecycle)
        self.assertIn("session.paused", lifecycle)
        self.assertIn("main._toggle_pause()", lifecycle)
        self.assertIn("_paused_by_lifecycle = true", lifecycle)

    def test_resume_only_reverses_a_lifecycle_pause(self):
        lifecycle = (ROOT / "src" / "app_lifecycle.gd").read_text(encoding="utf-8")
        self.assertIn("if not _paused_by_lifecycle:", lifecycle)
        self.assertIn("_paused_by_lifecycle = false", lifecycle)


if __name__ == "__main__":
    unittest.main()
