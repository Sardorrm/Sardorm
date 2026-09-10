# Android compatibility audit

## Repository-verified configuration

- Godot 4.3 project using the GL Compatibility renderer.
- Portrait mobile viewport: 720x1280 with a 360x640 window override.
- `stretch/mode` is `canvas_items` for scalable UI/content.
- `handheld/orientation=1` requests portrait orientation for handheld devices.
- Mobile renderer is explicitly `gl_compatibility`.
- The project name/version are declared in `project.godot`.

## Export configuration gate

`./scripts/validate_android_export.py` is executed by the Godot Check workflow. It verifies the Android-first project settings above and, when `export_presets.cfg` exists, validates that an Android preset has a package identifier without embedded release credentials.

The repository currently does **not** contain `export_presets.cfg`. The audit intentionally reports this as `ANDROID_EXPORT_PRESET=missing` and exits successfully so CI does not pretend that an export preset or signed release build exists.

## Release boundary

This audit is repository/CI verification only. It does not prove:

- a successful Android APK/AAB export from the user's local Godot installation;
- signing with release keystore credentials;
- installation or gameplay on a physical Android device;
- Play Store submission readiness.

Those checks remain explicit release-gate work for later hours and require the appropriate external environment/credentials/device.
