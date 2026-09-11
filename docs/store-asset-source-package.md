# MindShift Store Asset Source Package

Hour 49 source artwork and verification checklist. These files are release-oriented source assets, not a claim that a storefront has approved or uploaded them.

## Committed source assets

- `assets/store/mindshift_launcher.svg` — 512×512 launcher/store icon source with a centered, legible mark.
- `assets/store/mindshift_adaptive_foreground.svg` — 432×432 adaptive-icon foreground source; keep the mark inside the safe center region when configuring the Android adaptive icon.
- `assets/store/mindshift_feature_graphic.svg` — 1024×500 feature-graphic source with MindShift product identity and no debug data.

## Release handling

1. Rasterize/export the launcher and adaptive-icon sources through the final Android/Godot release pipeline.
2. Review the icon at small rendered sizes and confirm there is no clipping or unreadable detail.
3. Configure the adaptive foreground/background in the release export configuration once the production package ID/signing setup exists.
4. Capture final gameplay screenshots from the signed release candidate rather than fabricating screenshots in source control.
5. Replace or revise the source artwork if the owner supplies final brand artwork; do not treat this source package as storefront approval.

## Explicit remaining gates

- Production package ID and signing credentials are external release-account inputs.
- Real Android device verification and final screenshot capture require a physical Android device.
- Store listing copy, category/tags, support URL, privacy-policy URL, rating and data-safety declarations remain owner/storefront decisions.
