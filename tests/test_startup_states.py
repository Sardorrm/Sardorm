from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class StartupStateContractTests(unittest.TestCase):
    def test_startup_state_is_registered_as_autoload(self):
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        startup = (ROOT / "src" / "startup_state.gd").read_text(encoding="utf-8")
        self.assertIn('MindShiftStartupState="*res://src/startup_state.gd"', project)
        self.assertIn('extends CanvasLayer', startup)

    def test_loading_state_is_explicit_and_non_interactive(self):
        startup = (ROOT / "src" / "startup_state.gd").read_text(encoding="utf-8")
        self.assertIn('message.text = "MindShift\\nYuklanmoqda..."', startup)
        self.assertIn('retry_button.visible = false', startup)

    def test_error_state_has_retry_path(self):
        startup = (ROOT / "src" / "startup_state.gd").read_text(encoding="utf-8")
        self.assertIn('func show_error(title: String, detail: String, retry_callback: Callable = Callable()) -> void:', startup)
        self.assertIn('retry_button.text = "QAYTA URINISH"', startup)
        self.assertIn('get_tree().reload_current_scene()', startup)

    def test_empty_state_can_return_to_parent_screen(self):
        startup = (ROOT / "src" / "startup_state.gd").read_text(encoding="utf-8")
        self.assertIn('func show_empty(title: String, detail: String, back_callback: Callable = Callable()) -> void:', startup)
        self.assertIn('retry_button.text = "ORTGA"', startup)

    def test_startup_watch_does_not_hide_failure_when_main_ui_is_missing(self):
        startup = (ROOT / "src" / "startup_state.gd").read_text(encoding="utf-8")
        self.assertIn('if scene != null and scene.get_child_count() > 0:', startup)
        self.assertIn('show_error("MindShift ishga tushmadi"', startup)


if __name__ == "__main__":
    unittest.main()
