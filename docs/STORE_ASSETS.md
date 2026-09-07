# MindShift Store Assets & Listing Checklist

Release-readiness checklist for Google Play and other Android storefronts. This document tracks required source material; it does not claim that store assets have been uploaded or approved.

## Product identity

- [ ] Final app name: MindShift
- [ ] Final application/package ID selected and documented
- [ ] Final release version and version code selected
- [ ] Final short description approved
- [ ] Final full description approved
- [ ] Category and tags selected
- [ ] Contact/support URL selected
- [ ] Privacy policy URL selected

## Icon and graphics

- [ ] Production launcher icon exported from the final artwork
- [ ] Adaptive icon foreground/background prepared
- [ ] Icon checked for legibility at small size
- [ ] Store feature graphic prepared if required by the target storefront
- [ ] No temporary/debug artwork remains in release assets

## Screenshots

- [ ] Portrait gameplay screenshot showing the Home screen
- [ ] Portrait screenshot showing a puzzle/input state
- [ ] Portrait screenshot showing result/progression feedback
- [ ] Portrait screenshot showing Daily Challenge/streak
- [ ] Screenshots use the final production UI and contain no debug data
- [ ] Screenshots checked for clipping, safe-area issues and readable text
- [ ] Screenshot set exported at the storefront's required dimensions

## Listing and compliance

- [ ] Content rating questionnaire completed
- [ ] Target audience declaration completed
- [ ] Data safety/privacy disclosures completed from the final telemetry implementation
- [ ] Ads/in-app purchase declarations completed if applicable
- [ ] App access/test-account instructions supplied if applicable
- [ ] Store listing localization reviewed

## Release evidence

- [ ] Release build installed and smoke-tested on a real Android device
- [ ] Final screenshots captured from the release candidate where practical
- [ ] Package ID, version and signing configuration verified
- [ ] No known P0/P1 defects

## Current blockers

- Real Android device capture/verification has not been performed in this repository environment.
- Final package ID/signing credentials depend on the release account.
- Final store artwork and policy URLs require owner-provided production decisions/assets.
