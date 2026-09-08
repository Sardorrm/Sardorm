# Android release export audit

MindShift is configured as an Android-first Godot 4.3 project. Release export is deliberately separated from credentials and physical-device verification.

## CI-safe gate

Run:

```text
python3 scripts/validate_android_export.py
```

The audit verifies the Android-first project configuration. If `export_presets.cfg` is committed, it also verifies that an Android preset exists, has a package identifier, and does not contain embedded signing passwords or non-debug keystore values.

A missing `export_presets.cfg` is reported as `ANDROID_EXPORT_PRESET=missing` and remains a release blocker. CI must not interpret that result as proof of an Android export.

## Release gate outside CI

1. Open the project in the pinned Godot 4.3 toolchain.
2. Configure the Android export preset and application/package identity without committing signing secrets.
3. Produce a release candidate APK/AAB with the real signing credentials supplied through the local/CI secret store.
4. Install the exact artifact on a physical Android device.
5. Verify launch, touch/input, puzzle completion, hints/lives, save, process restart, and save restoration.
6. Record artifact version, device/Android version, and pass/fail evidence in the Hour 18 Notion task.

No emulator or headless CI result is a substitute for step 4 or step 5.
