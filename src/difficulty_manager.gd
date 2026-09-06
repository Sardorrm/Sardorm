class_name DifficultyManager
extends RefCounted

const TIER_NAMES := {
    1: "Boshlang‘ich",
    2: "O‘rta",
    3: "Murakkab",
    4: "Ekspert",
    5: "MindShift"
}

const TIME_LIMITS := {1: 90, 2: 75, 3: 60, 4: 50, 5: 40}
const SCORE_MULTIPLIERS := {1: 1.0, 2: 1.15, 3: 1.35, 4: 1.6, 5: 2.0}

static func tier_name(difficulty: int) -> String:
    return str(TIER_NAMES.get(clampi(difficulty, 1, 5), "MindShift"))

static func time_limit(difficulty: int) -> int:
    return int(TIME_LIMITS.get(clampi(difficulty, 1, 5), 40))

static func score_multiplier(difficulty: int) -> float:
    return float(SCORE_MULTIPLIERS.get(clampi(difficulty, 1, 5), 1.0))

static func is_hard(difficulty: int) -> bool:
    return difficulty >= 4

static func recommended_time(puzzle: PuzzleDefinition) -> int:
    if puzzle == null:
        return 0
    if puzzle.time_limit_seconds > 0:
        return int(puzzle.time_limit_seconds)
    return time_limit(puzzle.difficulty)
