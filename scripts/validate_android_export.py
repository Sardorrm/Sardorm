#!/usr/bin/env python3
"""Audit the repository for a credential-free Android export configuration.

This intentionally does not attempt signing or device verification. It provides a
stable CI-readable gate: project.godot must be Android-first, and an export preset
may be validated when present. Missing presets are reported as an external release
blocker rather than silently treated as a successful device/export test.
"""
from pathlib import Path
import configparser

root = Path(__file__).resolve().parents[1]
project = root / "project.godot"
presets = root / "export_presets.cfg"

text = project.read_text(encoding="utf-8")
assert 'config/name="MindShift"' in text
assert 'config/features=PackedStringArray("4.3", "GL Compatibility")' in text
assert 'handheld/orientation=1' in text
assert 'renderer/rendering_method.mobile="gl_compatibility"' in text

if not presets.exists():
    print("ANDROID_EXPORT_PRESET=missing")
    print("ANDROID_EXPORT_BLOCKER=export_presets.cfg is not committed; configure export in Godot before release")
    raise SystemExit(0)

parser = configparser.ConfigParser()
parser.optionxform = str
parser.read(presets, encoding="utf-8")
android_presets = [s for s in parser.sections() if s.startswith("preset.") and not s.endswith(".options") and parser.get(s, "platform", fallback="") == "Android"]
assert android_presets, "No Android preset found"
for section in android_presets:
    options = section + ".options"
    package = parser.get(options, "package/unique_name", fallback="") if parser.has_section(options) else ""
    assert package, f"Android preset {section} has no package/unique_name"
    for key, value in (parser.items(options) if parser.has_section(options) else []):
        lowered = value.lower()
        assert "password" not in key.lower()
        assert "password" not in lowered
        assert "keystore" not in lowered or "debug" in lowered
print(f"ANDROID_EXPORT_PRESET=validated ({len(android_presets)} Android preset(s))")
print("ANDROID_EXPORT_CREDENTIALS=not embedded")
