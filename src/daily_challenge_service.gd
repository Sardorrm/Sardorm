class_name DailyChallengeService
extends RefCounted

const CHALLENGE_SIZE := 3

var repository: PuzzleRepository
var completed_dates: Array = []
var current_date := ""
var current_indices: Array = []
var completed_count := 0
var current_position := 0

func setup(puzzle_repository: PuzzleRepository, save_data: Dictionary = {}) -> void:
    repository = puzzle_repository
    var stored = save_data.get("daily_challenges", {})
    if typeof(stored) == TYPE_DICTIONARY:
        completed_dates = stored.get("completed_dates", []).duplicate()
        var stored_date := str(stored.get("date", ""))
        if stored_date == DailyChallenge.date_key():
            completed_count = clampi(int(stored.get("completed_count", 0)), 0, CHALLENGE_SIZE)
            current_position = clampi(int(stored.get("current_position", completed_count)), 0, CHALLENGE_SIZE)
    refresh()

func refresh(unix_time: int = -1) -> void:
    var next_date := DailyChallenge.date_key(unix_time)
    var date_changed := next_date != current_date
    current_date = next_date
    var count := repository.puzzles.size() if repository != null else 0
    current_indices = DailyChallenge.select_indices(count, current_date, CHALLENGE_SIZE)
    if date_changed:
        completed_count = 0
        current_position = 0
    else:
        completed_count = clampi(completed_count, 0, min(CHALLENGE_SIZE, current_indices.size()))
        current_position = clampi(current_position, 0, current_indices.size())

func get_puzzles() -> Array:
    var result: Array = []
    if repository == null:
        return result
    for index in current_indices:
        if index >= 0 and index < repository.puzzles.size():
            result.append(repository.puzzles[index])
    return result

func reset_progress() -> void:
    completed_count = 0
    current_position = 0

func record_solved() -> void:
    if current_position >= current_indices.size():
        return
    completed_count = mini(CHALLENGE_SIZE, completed_count + 1)
    current_position = mini(current_indices.size(), current_position + 1)

func record_failed() -> void:
    current_position = mini(current_indices.size(), current_position + 1)

func is_completed() -> bool:
    return current_date in completed_dates

func is_session_completed() -> bool:
    return current_position >= current_indices.size() and completed_count >= mini(CHALLENGE_SIZE, current_indices.size()) and not current_indices.is_empty()

func mark_completed() -> void:
    if is_session_completed() and not is_completed():
        completed_dates.append(current_date)

func get_completed_dates_count() -> int:
    return completed_dates.size()

func to_dict() -> Dictionary:
    return {
        "date": current_date,
        "indices": current_indices.duplicate(),
        "completed_count": completed_count,
        "current_position": current_position,
        "completed_dates": completed_dates.duplicate()
    }
