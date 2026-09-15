from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
THEME = ROOT / "themes" / "mindshift_theme.tres"

REQUIRED_CONTROLS = ("Button", "OptionButton", "CheckButton")
REQUIRED_STATES = ("normal", "hover", "pressed", "disabled", "focus")
REQUIRED_RADIUS_TOKENS = (
    "corner_radius_top_left = 16",
    "corner_radius_top_right = 16",
    "corner_radius_bottom_right = 16",
    "corner_radius_bottom_left = 16",
)


def _relative_luminance(rgb):
    channels = []
    for channel in rgb:
        channels.append(channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4)
    return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]


def _contrast_ratio(foreground, background):
    foreground_l = _relative_luminance(foreground)
    background_l = _relative_luminance(background)
    light, dark = max(foreground_l, background_l), min(foreground_l, background_l)
    return (light + 0.05) / (dark + 0.05)


def main() -> None:
    text = THEME.read_text(encoding="utf-8")

    if '[gd_resource type="Theme" load_steps=9 format=3]' not in text:
        raise SystemExit("theme load_steps contract is invalid")

    if '[sub_resource type="StyleBoxFlat" id="ButtonFocus"]' not in text:
        raise SystemExit("premium ButtonFocus style is missing")
    if '[sub_resource type="StyleBoxFlat" id="LineEditFocus"]' not in text:
        raise SystemExit("premium LineEditFocus style is missing")

    for control in REQUIRED_CONTROLS:
        for state in REQUIRED_STATES:
            expected = f'{control}/styles/{state} = SubResource("Button{state.capitalize()}")'
            if expected not in text:
                raise SystemExit(f"missing {control} {state} style")
        if f"{control}/font_sizes/font_size = 19" not in text:
            raise SystemExit(f"missing {control} typography contract")
        if f"{control}/colors/font_disabled_color = Color(0.40, 0.41, 0.50, 1)" not in text:
            raise SystemExit(f"missing {control} disabled readability contract")

    if not re.search(r"border_color = Color\(0\.70, 0\.72, 1, 1\)", text):
        raise SystemExit("focus contrast token is missing")

    if _contrast_ratio((0.40, 0.41, 0.50), (0.07, 0.07, 0.10)) < 3.0:
        raise SystemExit("disabled control text contrast is below 3:1")
    if _contrast_ratio((0.48, 0.49, 0.58), (0.08, 0.08, 0.12)) < 4.5:
        raise SystemExit("placeholder text contrast is below 4.5:1")
    if _contrast_ratio((0.93, 0.93, 0.98), (0.055, 0.058, 0.09)) < 4.5:
        raise SystemExit("label text contrast is below 4.5:1")
    if _contrast_ratio((0.70, 0.72, 1.0), (0.12, 0.12, 0.19)) < 3.0:
        raise SystemExit("focus indicator contrast is below 3:1")

    for token in REQUIRED_RADIUS_TOKENS:
        if text.count(token) < 5:
            raise SystemExit(f"premium radius token is under-applied: {token}")

    if 'LineEdit/styles/normal = SubResource("LineEditNormal")' not in text:
        raise SystemExit("LineEdit normal style is missing")
    if 'LineEdit/styles/focus = SubResource("LineEditFocus")' not in text:
        raise SystemExit("LineEdit focus style is missing")
    if "LineEdit/font_sizes/font_size = 20" not in text:
        raise SystemExit("LineEdit typography contract is missing")
    if "Label/font_sizes/font_size = 18" not in text:
        raise SystemExit("Label typography contract is missing")


if __name__ == "__main__":
    main()
