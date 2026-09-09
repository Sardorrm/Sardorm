from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class BackNavigationContractTests(unittest.TestCase):
    def test_system_back_is_centralized_and_consumed(self):
        code = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        self.assertIn("func _unhandled_input(event: InputEvent)", code)
        self.assertIn('event.is_action_pressed("ui_cancel")', code)
        self.assertIn("get_viewport().set_input_as_handled()", code)

    def test_active_puzzle_back_maps_to_pause(self):
        code = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        self.assertIn("if active_puzzle != null and session.state == GameSession.STATE_ACTIVE and not puzzle_finished:", code)
        self.assertIn("_toggle_pause()", code)

    def test_non_game_back_returns_to_home(self):
        code = (ROOT / "src" / "main.gd").read_text(encoding="utf-8")
        self.assertIn("else:\n        _show_home()", code)
        self.assertIn('content.add_child(_button("ORTGA", _show_home))', code)

    def test_back_contract_documented_for_android_gate(self):
        contract = (ROOT / "docs" / "navigation_contract.md").read_text(encoding="utf-8")
        self.assertIn("Back", contract)
        self.assertIn("physical Android device", contract)


if __name__ == "__main__":
    unittest.main()
