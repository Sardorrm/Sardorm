class_name DifficultyManager
extends RefCounted

const TIER_NAMES := {
    1: "Boshlang‘ich",
    2: "O‘rta",
    3: "Murakkab",
    4: "Ekspert",
    5: "MindShift"
}

static func tier_name(difficulty: int) -> String:
    return str(TIER_NAMES.get(clampi(difficulty, 1, 5), "MindShift"))

static func time_limit(difficulty: int) -> int:
    return [0, 90, 75, 60, 50, 40][clampi(difficulty, 1, 5)]

static func is_hard(difficulty: int) -> bool:
    return difficulty >= 4
