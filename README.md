# MindShift 🧠

MindShift is a mobile-first intellectual puzzle game built around one idea: **don't just find the answer — change the way you think.**

## Current build
- 35 deterministic puzzles across pattern, logic, sequence, observation, spatial, assumption and MindShift categories
- Four answer modes: text, number, multiple choice and true/false
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

## Development workflow
Notion is the product/project source of truth. GitHub is the code and engineering source of truth.

Idea → Notion task → GitHub issue → implementation → commit → tests/CI → inspect result → update project status.

## Project structure
- `docs/` — game design, architecture and product-balance documentation
- `data/` — puzzle definitions
- `src/` — Godot runtime and gameplay systems
- `tests/` — automated integrity and architecture-contract tests
- `.github/` — CI automation

## Gameplay systems
The campaign and Daily Challenge are intentionally separated: solving a Daily Challenge puzzle contributes to statistics and achievements but does not silently unlock campaign levels. Difficulty score multipliers are centralized in `GameRules`, while Daily streak multipliers apply only to Daily Challenge rewards.

## Status
The playable core, progression, Daily Challenge, lives, streaks, statistics, achievements and automated validation foundations are implemented. Remaining release work includes expanding the reviewed puzzle library, deeper difficulty balancing, full Android device QA, visual/audio polish, Android export configuration, store assets and final release validation.
