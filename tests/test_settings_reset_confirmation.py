from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
GUARD = ROOT / "src" / "settings_reset_guard.gd"
PROJECT = ROOT / "project.godot"


def test_reset_guard_is_registered_and_targets_settings_reset_button():
    guard = GUARD.read_text(encoding="utf-8")
    project = PROJECT.read_text(encoding="utf-8")

    assert 'MindShiftSettingsResetGuard="*res://src/settings_reset_guard.gd"' in project
    assert 'const RESET_BUTTON_TEXT := "PROGRESSNI TOZALASH"' in guard
    assert 'callback.get_method() == "_reset_progress"' in guard


def test_reset_guard_requires_explicit_confirmation_before_clearing():
    guard = GUARD.read_text(encoding="utf-8")

    assert "ConfirmationDialog.new()" in guard
    assert 'dialog.ok_button_text = "TOZALASH"' in guard
    assert 'dialog.cancel_button_text = "BEKOR QILISH"' in guard
    assert 'dialog.confirmed.connect' in guard
    assert "SaveManager.clear_progress()" in guard
    assert "dialog.canceled.connect(dialog.queue_free)" in guard
