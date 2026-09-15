from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
THEME = ROOT / "themes" / "mindshift_theme.tres"

REQUIRED_CONTROLS = ("Button", "OptionButton", "CheckButton")
REQUIRED_STATES = ("normal", "hover", "pressed", "disabled", "focus")


def main() -> None:
    text = THEME.read_text(encoding="utf-8")

    if '[gd_resource type="Theme" load_steps=9 format=3]' not in text:
        raise SystemExit("theme load_steps contract is invalid")

    if 'SubResource type="StyleBoxFlat" id="ButtonFocus"' not in text:
        raise SystemExit("premium ButtonFocus style is missing")

    for control in REQUIRED_CONTROLS:
        for state in REQUIRED_STATES:
            expected = f'{control}/styles/{state} = SubResource("Button{state.capitalize()}")'
            if expected not in text:
                raise SystemExit(f"missing {control} {state} style")

    for control in REQUIRED_CONTROLS:
        if f"{control}/font_sizes/font_size = 19" not in text:
            raise SystemExit(f"missing {control} typography contract")
        if f"{control}/colors/font_disabled_color = Color(0.40, 0.41, 0.50, 1)" not in text:
            raise SystemExit(f"missing {control} disabled readability contract")

    if not re.search(r"border_color = Color\(0\.70, 0\.72, 1, 1\)", text):
        raise SystemExit("focus contrast token is missing")


if __name__ == "__main__":
    main()
