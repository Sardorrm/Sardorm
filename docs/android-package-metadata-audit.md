# Android Package / Application Metadata Audit

## Audited source

`project.godot` is the source currently present in the repository for application-level metadata.

Verified values:

- Application name: `MindShift`
- Application version: `0.1.0`
- Main scene: `res://src/MainScene.tscn`
- Portrait orientation is enabled.
- Mobile renderer is explicitly `gl_compatibility`.

## Release configuration status

The repository currently has **no `export_presets.cfg`** on `main`. Therefore an Android export preset containing the final package identifier, release signing configuration, and export-specific version metadata is not yet represented in source control.

This is intentional rather than guessed: a production Android application/package identifier and signing setup must be chosen for the real release account. Inventing a package ID or committing signing material would create a release risk.

### Required before Android release

1. Add a committed Android export preset with the final package/unique application identifier.
2. Confirm the version code/version name strategy and keep it reproducible from source.
3. Configure release signing using the real release credentials outside the repository; never commit keystores or passwords.
4. Build an Android release artifact and verify install/startup on a physical Android device.
5. Record the final package identifier and release artifact version in the launch checklist.

## Acceptance boundary

The repository metadata itself is internally consistent and machine-tested. Final package identifier/signing and physical-device verification remain release-account/device gates and are not claimed as complete by CI.
