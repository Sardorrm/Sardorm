from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_three_languages_and_persistent_selector_contract():
    code = (ROOT / "src" / "locale_runtime_fixed.gd").read_text(encoding="utf-8")
    project = (ROOT / "project.godot").read_text(encoding="utf-8")
    assert 'const LANGUAGES := ["uz", "ru", "en"]' in code
    assert '"DAVOM ETISH":"ПРОДОЛЖИТЬ"' in code
    assert '"DAVOM ETISH":"CONTINUE"' in code
    assert 'func set_language(next_language: String) -> void:' in code
    assert 'settings["language"] = language' in code
    assert 'MindShiftLocaleRuntime="*res://src/locale_runtime_fixed.gd"' in project


def test_selector_has_all_language_buttons_and_safe_default():
    code = (ROOT / "src" / "locale_runtime_fixed.gd").read_text(encoding="utf-8")
    assert 'var stored := str(data.get("settings", {}).get("language", "uz"))' in code
    assert 'language = stored if stored in LANGUAGES else "uz"' in code
    assert 'for code in LANGUAGES:' in code
    assert 'button.name = "Language_" + code' in code


def test_broken_duplicate_runtime_was_removed():
    assert not (ROOT / "src" / "locale_runtime.gd").exists()
