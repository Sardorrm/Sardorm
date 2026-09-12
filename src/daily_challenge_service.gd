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
        completed_dates = _sanitize_completed_dates(stored.get("completed_dates", []))
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
    # Re-evaluate the date whenever the UI asks for the challenge. This handles
    # an app that stays open across local midnight without requiring a restart.
    refresh()
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
    # A failed/timeout daily puzzle remains retryable. Advancing here would
    # skip the puzzle and could make the session impossible to complete.
    current_position = clampi(current_position, 0, current_indices.size())

func is_completed() -> bool:
    refresh()
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

func _sanitize_completed_dates(value) -> Array:
    var result: Array = []
    if typeof(value) != TYPE_ARRAY:
        return result
    for item in value:
        var key := str(item).strip_edges()
        if _is_valid_date_key(key) and not result.has(key):
            result.append(key)
    return result

func _is_valid_date_key(value: String) -> bool:
    if value.length() != 10 or value[4] != "-" or value[7] != "-":
        return false
    var parts := value.split("-")
    if parts.size() != 3:
        return false
    for part in parts:
        if not part.is_valid_int():
            return false
    var year := int(parts[0])
    var month := int(parts[1])
    var day := int(parts[2])
    if parts[0].length() != 4 or parts[1].length() != 2 or parts[2].length() != 2:
        return false
    if month < 1 or month > 12 or day < 1:
        return false
    var days_in_month := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if _is_leap_year(year):
        days_in_month[1] = 29
    return day <= days_in_month[month - 1]

func _is_leap_year(year: int) -> bool:
    return year % 400 == 0 or (year % 4 == 0 and year % 100 != 0)
