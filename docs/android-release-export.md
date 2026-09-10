# Android release export audit

MindShift is configured as an Android-first Godot 4.3 project. Release export is deliberately separated from credentials and physical-device verification.

## CI-safe gate

Run:

```text
python3 scripts/validate_android_export.py
```

The audit verifies the Android-first project configuration. If `export_presets.cfg` is committed, it also verifies that an Android preset exists, has a package identifier, and does not contain embedded signing passwords or non-debug keystore values.

A missing `export_presets.cfg` is reported as `ANDROID_EXPORT_PRESET=missing` and remains a release blocker. CI must not interpret that result as proof of an Android export.

## Release export procedure

1. Open the project in the pinned Godot 4.3 toolchain.
2. Configure an Android export preset using the real publishing package identifier. Do not invent or substitute a package ID for the production account.
3. Review the preset diff and repository status to ensure signing passwords, keystores, and other release secrets are not committed.
4. Produce a release candidate APK/AAB with the real signing credentials supplied through the local/CI secret store.
5. Record the artifact version/code and checksum.
6. Install the exact artifact on a physical Android device.
7. Verify launch, portrait/safe-area layout, touch/input, puzzle completion, hints/lives, save, process restart, and save restoration.
8. Record device/Android version and pass/fail evidence in the launch checklist.

No emulator or headless CI result is a substitute for physical-device verification.

## Current gate

`export_presets.cfg` is intentionally absent until the real package identifier and signing setup are supplied for the publishing account. This is an external release-account gate, not a CI failure to hide or bypass.
