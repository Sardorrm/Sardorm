from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "src" / "main.gd"


def test_cancel_input_is_handled_once_and_only_for_active_game_or_home_navigation():
    code = MAIN.read_text(encoding="utf-8")
    body = code.split("func _unhandled_input(event: InputEvent) -> void:", 1)[1].split("func _build_shell", 1)[0]
    assert 'if not event.is_action_pressed("ui_cancel"):' in body
    assert 'get_viewport().set_input_as_handled()' in body
    assert 'session.state == GameSession.STATE_ACTIVE' in body
    assert 'not puzzle_finished' in body


def test_answer_submission_is_guarded_against_stale_or_paused_input():
    code = MAIN.read_text(encoding="utf-8")
    body = code.split("func _submit_answer(", 1)[1].split("func _next_level", 1)[0]
    assert "if puzzle_finished or active_puzzle == null" in body
    assert "session.state != GameSession.STATE_ACTIVE" in body
    assert "session.paused" in body


def test_timer_tick_does_not_poll_when_gameplay_is_not_active():
    code = MAIN.read_text(encoding="utf-8")
    body = code.split("func _on_timer_tick() -> void:", 1)[1].split("func _handle_timeout", 1)[0]
    assert "if active_puzzle == null or puzzle_finished or session.paused or timer_label == null:" in body
    assert "session.check_timeout()" in body
    assert "session.get_remaining_seconds()" in body
