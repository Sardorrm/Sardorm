class_name DailyChallengeService
extends RefCounted

const CHALLENGE_SIZE := 3

var repository: PuzzleRepository
var completed_dates: Array = []
var current_date := ""
var current_indices: Array = []
var completed_count := 0

func setup(puzzle_repository: PuzzleRepository, save_data: Dictionary = {}) -> void:
    repository = puzzle_repository
    var stored = save_data.get("daily_challenges", {})
    if typeof(stored) == TYPE_DICTIONARY:
        completed_dates = stored.get("completed_dates", []).duplicate()
    refresh()

func refresh(unix_time: int = -1) -> void:
    current_date = DailyChallenge.date_key(unix_time)
    var count := repository.puzzles.size() if repository != null else 0
    current_indices = DailyChallenge.select_indices(count, current_date, CHALLENGE_SIZE)
    completed_count = 0

func get_puzzles() -> Array:
    var result: Array = []
    if repository == null:
        return result
    for index in current_indices:
        if index >= 0 and index < repository.puzzles.size():
            result.append(repository.puzzles[index])
    return result

func is_completed() -> bool:
    return current_date in completed_dates

func mark_completed() -> void:
    if not is_completed():
        completed_dates.append(current_date)

func to_dict() -> Dictionary:
    return {
        "date": current_date,
        "indices": current_indices.duplicate(),
        "completed_dates": completed_dates.duplicate()
    }
