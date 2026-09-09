from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "src" / "main.gd"


def test_settings_controls_are_persistent():
    source = MAIN.read_text(encoding="utf-8")

    assert 'settings = {"sound": true, "haptics": true}.merged(save_data.get("settings", {}))' in source
    assert 'settings["sound"] = not bool(settings.get("sound", true))' in source
    assert 'settings["haptics"] = not bool(settings.get("haptics", true))' in source
    assert "_save()" in source


def test_settings_screen_exposes_both_controls_and_reset_action():
    source = MAIN.read_text(encoding="utf-8")

    assert 'content.add_child(_button(sound_text, _toggle_sound, 60))' in source
    assert 'content.add_child(_button(haptics_text, _toggle_haptics, 60))' in source
    assert 'content.add_child(_button("PROGRESSNI TOZALASH", _reset_progress, 60))' in source
