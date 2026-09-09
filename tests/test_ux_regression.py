from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"


def read_source(name: str) -> str:
    return (SRC / name).read_text(encoding="utf-8")


def test_main_shell_keeps_primary_touch_targets_and_safe_margin():
    source = read_source("main.gd")
    assert 'set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)' in source
    assert 'margin_left", 24' in source
    assert 'margin_right", 24' in source
    assert 'custom_minimum_size = Vector2(0, maxi(64, height))' in source


def test_primary_navigation_actions_are_reachable_from_home():
    source = read_source("main.gd")
    for label in (
        '"DAVOM ETISH"',
        '"BUGUNGI CHALLENGE"',
        '"DARAJALAR"',
        '"STATISTIKA"',
        '"YUTUQLAR"',
        '"SOZLAMALAR"',
    ):
        assert label in source
    assert 'content.add_child(_button("ORTGA", _show_home))' in source


def test_puzzle_loop_exposes_feedback_hint_pause_and_next_actions():
    source = read_source("main.gd")
    for marker in (
        'content.add_child(_button("HINT"',
        'pause_button = _button("⏸ PAUZA"',
        'content.add_child(_button("DARAJALAR"',
        'content.add_child(_button("KEYINGI DARAJA"',
        'feedback.text = "✓ TO‘G‘RI!',
        'feedback.text = "Hali emas.',
    ):
        assert marker in source


def test_back_and_lifecycle_contracts_remain_wired():
    main = read_source("main.gd")
    lifecycle = read_source("app_lifecycle.gd")
    assert 'func _unhandled_input(event: InputEvent)' in main
    assert 'event.is_action_pressed("ui_cancel")' in main
    assert 'get_viewport().set_input_as_handled()' in main
    assert 'NOTIFICATION_APPLICATION_PAUSED' in lifecycle
    assert 'NOTIFICATION_APPLICATION_RESUMED' in lifecycle


def test_settings_and_achievement_surfaces_remain_in_main_flow():
    source = read_source("main.gd")
    assert 'settings = {"sound": true, "haptics": true}.merged(save_data.get("settings", {}))' in source
    assert 'achievements.load_from_dict(save_data.get("achievements", {}))' in source
    assert 'func _show_settings()' in source
    assert 'func _show_achievements()' in source


def test_startup_recovery_contract_is_present():
    source = read_source("startup_state.gd")
    assert 'func show_error' in source
    assert 'func show_empty' in source
    assert 'func retry' in source
    assert 'func back' in source
