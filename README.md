# MindShift 🧠

MindShift is a mobile-first intellectual puzzle game built around one idea: **don't just find the answer — change the way you think.**

## Current build
- 30 deterministic puzzles across pattern, logic, sequence, observation, spatial, assumption and MindShift categories
- Godot 4 portrait runtime foundation
- Puzzle engine with numeric and text answer validation
- Level unlocking and completion tracking
- Hint system
- Local progress/save system with versioned data
- Player reasoning statistics and profile
- Mobile-first menu, level selection, puzzle, statistics and settings screens
- Automated puzzle integrity tests and GitHub Actions validation

## Development workflow
Notion is the product/project source of truth. GitHub is the code and engineering source of truth.

Idea → Notion task → GitHub issue → implementation → commit → tests/CI → inspect result → update project status.

## Project structure
- `docs/` — game design and technical documentation
- `data/` — puzzle definitions
- `src/` — Godot runtime and game systems
- `tests/` — automated integrity tests
- `.github/` — CI automation

## Status
Playable core and progression foundation are implemented. Remaining release work includes deeper content expansion, full Godot runtime/device QA, polish, Android export configuration, store assets and final release validation.
