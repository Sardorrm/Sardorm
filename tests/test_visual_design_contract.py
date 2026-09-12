from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_premium_background_asset_exists():
    path = ROOT / "assets" / "backgrounds" / "mindshift_cognitive_bg.svg"
    assert path.exists()
    text = path.read_text(encoding="utf-8")
    assert "<svg" in text
    assert "720" in text and "1280" in text


def test_background_autoload_is_responsive_and_noninteractive():
    code = (ROOT / "src" / "visual_backgrounds.gd").read_text(encoding="utf-8")
    assert "STRETCH_KEEP_ASPECT_COVERED" in code
    assert "MOUSE_FILTER_IGNORE" in code
    assert "PRESET_FULL_RECT" in code
    assert "MindShiftVisualBackground" in code


def test_project_registers_visual_background_autoload():
    project = (ROOT / "project.godot").read_text(encoding="utf-8")
    assert 'MindShiftVisualBackgrounds="*res://src/visual_backgrounds.gd"' in project
