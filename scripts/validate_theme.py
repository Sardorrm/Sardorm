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
COLOR_RE = re.compile(r"(?P<key>[A-Za-z_]+(?:/[A-Za-z_]+)*) = Color\((?P<values>[^)]+)\)")
SUBRESOURCE_RE = re.compile(
    r'\[sub_resource type="StyleBoxFlat" id="(?P<id>[^"]+)"\](?P<body>.*?)(?=\n\[sub_resource|\n\[resource\]|\Z)',
    re.DOTALL,
)


def _relative_luminance(rgb):
    channels = [channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4 for channel in rgb]
    return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]


def _contrast_ratio(foreground, background):
    foreground_l = _relative_luminance(foreground)
    background_l = _relative_luminance(background)
    light, dark = max(foreground_l, background_l), min(foreground_l, background_l)
    return (light + 0.05) / (dark + 0.05)


def _theme_color(text, key, section=None):
    scope = text
    if section is not None:
        match = next((match for match in SUBRESOURCE_RE.finditer(text) if match.group("id") == section), None)
        if match is None:
            raise SystemExit(f"missing theme subresource: {section}")
        scope = match.group("body")
    match = next((match for match in COLOR_RE.finditer(scope) if match.group("key") == key), None)
    if match is None:
        raise SystemExit(f"missing theme color: {section or 'resource'}:{key}")
    values = [float(value.strip()) for value in match.group("values").split(",")]
    if len(values) != 4:
        raise SystemExit(f"invalid RGBA token: {section or 'resource'}:{key}")
    return tuple(values[:3])


def main() -> None:
    text = THEME.read_text(encoding="utf-8")

    if '[gd_resource type="Theme" load_steps=10 format=3]' not in text:
        raise SystemExit("theme load_steps contract is invalid")

    if '[sub_resource type="StyleBoxFlat" id="ButtonFocus"]' not in text:
        raise SystemExit("premium ButtonFocus style is missing")
    if '[sub_resource type="StyleBoxFlat" id="LineEditFocus"]' not in text:
        raise SystemExit("premium LineEditFocus style is missing")
    if '[sub_resource type="StyleBoxFlat" id="LineEditDisabled"]' not in text:
        raise SystemExit("premium LineEditDisabled style is missing")

    for control in REQUIRED_CONTROLS:
        for state in REQUIRED_STATES:
            expected = f'{control}/styles/{state} = SubResource("Button{state.capitalize()}")'
            if expected not in text:
                raise SystemExit(f"missing {control} {state} style")
        if f"{control}/font_sizes/font_size = 19" not in text:
            raise SystemExit(f"missing {control} typography contract")
        if f"{control}/colors/font_disabled_color = Color(0.52, 0.53, 0.62, 1)" not in text:
            raise SystemExit(f"missing {control} disabled readability contract")

    if not re.search(r"border_color = Color\(0\.70, 0\.72, 1, 1\)", text):
        raise SystemExit("focus contrast token is missing")

    disabled_text = _theme_color(text, "Button/colors/font_disabled_color")
    disabled_bg = _theme_color(text, "bg_color", section="ButtonDisabled")
    placeholder = _theme_color(text, "LineEdit/colors/font_placeholder_color")
    input_bg = _theme_color(text, "bg_color", section="LineEditNormal")
    disabled_input_text = _theme_color(text, "LineEdit/colors/font_disabled_color")
    disabled_input_bg = _theme_color(text, "bg_color", section="LineEditDisabled")
    label = _theme_color(text, "Label/colors/font_color")
    panel_bg = _theme_color(text, "bg_color", section="Panel")
    focus = _theme_color(text, "border_color", section="ButtonFocus")
    focus_bg = _theme_color(text, "bg_color", section="ButtonFocus")
    input_focus = _theme_color(text, "border_color", section="LineEditFocus")
    input_focus_bg = _theme_color(text, "bg_color", section="LineEditFocus")

    if _contrast_ratio(disabled_text, disabled_bg) < 4.5:
        raise SystemExit("disabled control text contrast is below 4.5:1")
    if _contrast_ratio(placeholder, input_bg) < 4.5:
        raise SystemExit("placeholder text contrast is below 4.5:1")
    if _contrast_ratio(disabled_input_text, disabled_input_bg) < 4.5:
        raise SystemExit("disabled input text contrast is below 4.5:1")
    if _contrast_ratio(label, panel_bg) < 4.5:
        raise SystemExit("label text contrast is below 4.5:1")
    if _contrast_ratio(focus, focus_bg) < 3.0:
        raise SystemExit("focus indicator contrast is below 3:1")
    if _contrast_ratio(input_focus, input_focus_bg) < 3.0:
        raise SystemExit("input focus indicator contrast is below 3:1")

    for token in REQUIRED_RADIUS_TOKENS:
        if text.count(token) < 5:
            raise SystemExit(f"premium radius token is under-applied: {token}")

    if 'LineEdit/styles/normal = SubResource("LineEditNormal")' not in text:
        raise SystemExit("LineEdit normal style is missing")
    if 'LineEdit/styles/focus = SubResource("LineEditFocus")' not in text:
        raise SystemExit("LineEdit focus style is missing")
    if 'LineEdit/styles/disabled = SubResource("LineEditDisabled")' not in text:
        raise SystemExit("LineEdit disabled style is missing")
    if "LineEdit/font_sizes/font_size = 20" not in text:
        raise SystemExit("LineEdit typography contract is missing")
    if "Label/font_sizes/font_size = 18" not in text:
        raise SystemExit("Label typography contract is missing")


if __name__ == "__main__":
    main()
