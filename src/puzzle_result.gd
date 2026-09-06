class_name PuzzleResult
extends RefCounted

var puzzle_id := ""
var correct := false
var elapsed_seconds := 0.0
var failed_attempts := 0
var hint_used := false
var score := 0
var stars := 0
var difficulty := 1
var category := ""
var newly_unlocked: Array = []

func configure(puzzle: PuzzleDefinition, solved: bool, elapsed: float, attempts: int, used_hint: bool) -> PuzzleResult:
    puzzle_id = puzzle.id if puzzle != null else ""
    correct = solved
    elapsed_seconds = max(0.0, elapsed)
    failed_attempts = max(0, attempts - (1 if solved else 0))
    hint_used = used_hint
    difficulty = puzzle.difficulty if puzzle != null else 1
    category = puzzle.category if puzzle != null else ""
    if solved:
        score = GameRules.calculate_score(difficulty, elapsed_seconds, hint_used, failed_attempts)
        stars = GameRules.star_rating(difficulty, elapsed_seconds, hint_used, failed_attempts)
    return self

func to_dict() -> Dictionary:
    return {
        "puzzle_id": puzzle_id,
        "correct": correct,
        "elapsed_seconds": elapsed_seconds,
        "failed_attempts": failed_attempts,
        "hint_used": hint_used,
        "score": score,
        "stars": stars,
        "difficulty": difficulty,
        "category": category,
        "newly_unlocked": newly_unlocked.duplicate()
    }
