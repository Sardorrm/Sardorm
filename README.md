# MindShift 🧠

MindShift is a mobile-first intellectual puzzle game built around one idea: **don't just find the answer — change the way you think.**

## Current build
- 100 deterministic puzzles across pattern, logic, sequence, observation, spatial, assumption and MindShift categories
- Four answer modes: text, number, multiple choice and true/false
- Modular puzzle content packs (`data/puzzles.json` + `data/puzzles_extra.json`)
- Godot 4 portrait runtime foundation with touch-friendly UI
- Puzzle engine with normalized numeric/text answer validation and accepted-answer aliases
- Level unlocking and completion tracking
- One-use hint system with explanatory learning feedback
- Daily Challenge with 3 deterministic puzzles per date
- Daily Challenge progress resumes after app restart
- Daily streak and best-streak persistence with streak reward multipliers
- Three-life system with five-minute recovery
- Versioned local save system
- Player statistics, accuracy, average attempt time and reasoning profile
- Achievement system and gameplay event tracking
- Automated puzzle integrity tests and Godot headless CI validation
- Release-readiness checklist covering content, UX, QA, export and store preparation

## Development workflow
Notion is the product/project source of truth. GitHub is the code and engineering source of truth.

Idea → Notion task → GitHub issue → implementation → commit → tests/CI → inspect result → update project status.

## Project structure
- `docs/` — game design, architecture, product balance and release-readiness documentation
- `data/` — base and modular puzzle definitions
- `src/` — Godot runtime and gameplay systems
- `tests/` — automated integrity and architecture-contract tests
- `.github/` — CI automation

## Gameplay systems
The campaign and Daily Challenge are intentionally separated: solving a Daily Challenge puzzle contributes to statistics and achievements but does not silently unlock campaign levels. Difficulty score multipliers are centralized in `GameRules`, while Daily streak multipliers apply only to Daily Challenge rewards.

## Status
The project now has a 100-puzzle content library and modular loading. Remaining release work includes content review/localization, deeper difficulty balancing, full Android device QA, visual/audio polish, accessibility, save migration testing, Android export configuration, store assets and final release validation.
