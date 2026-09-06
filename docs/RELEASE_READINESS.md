# MindShift Release Readiness

## Product pillars

- [x] Core puzzle loop
- [x] Four answer modes: text, number, choice, true/false
- [x] Difficulty tiers 1–5
- [x] Hints and explanations
- [x] Campaign progression
- [x] Daily Challenge
- [x] Daily progress resume
- [x] Daily streak rewards
- [x] Lives
- [x] Persistent statistics
- [x] Achievements
- [x] Deterministic puzzle repository
- [x] Score + star result feedback
- [x] Mobile timer warning/critical feedback
- [x] Haptic feedback on mobile buttons

## Content quality gates

- [x] Unique puzzle IDs
- [x] Non-empty prompts and answers
- [x] Explanation for every puzzle
- [x] Difficulty metadata
- [x] Category/tag metadata contract
- [x] Multiple interaction types
- [x] Production puzzle library at 100 puzzles
- [x] Automated ambiguity/consistency review checks
- [ ] Review every puzzle for final Uzbek/Russian localization
- [ ] Balance difficulty progression using playtest data

## Mobile UX gates

- [x] Portrait-first 720×1280 design
- [x] 360×640 viewport override
- [x] Touch-oriented answer controls
- [x] Timer and progress feedback
- [x] Project-wide mobile dark theme with button/input/panel states
- [x] Result feedback shows stars, score, time and daily multiplier when applicable
- [ ] Final safe-area/device testing
- [ ] Final visual polish pass on real device
- [ ] Accessibility pass: text size, contrast, touch targets
- [ ] Back/pause/resume behavior review

## Technical release gates

- [x] Automated JSON/content validation
- [x] Python contract tests
- [x] Godot headless project validation workflow
- [x] CI project parse check passes
- [ ] Full Godot runtime test on device/emulator
- [ ] Save migration test across previous versions
- [ ] Final performance/memory check
- [ ] Release build/export verification

## Store readiness

- [ ] App icon
- [ ] Feature graphic
- [ ] Screenshots
- [ ] Store description
- [ ] Privacy policy URL if analytics/online services are enabled
- [ ] Final package ID/version strategy

## Definition of done

MindShift is release-ready when all unchecked release gates are completed and a clean build has been verified through the complete campaign, daily challenge, save/load, lives, hints, achievements, and statistics flows on a real Android device.
