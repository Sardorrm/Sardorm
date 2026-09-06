class_name LevelManager
extends RefCounted

var puzzle_engine: PuzzleEngine
var completed_levels: Array = []
var current_level: int = 0

func setup(engine: PuzzleEngine, save_data: Dictionary = {}) -> void:
    puzzle_engine = engine
    completed_levels = _sanitize_completed(save_data.get("completed_levels", []))
    current_level = clamp(int(save_data.get("current_level", 0)), 0, max(0, puzzle_engine.puzzles.size() - 1))

func _sanitize_completed(value) -> Array:
    var result: Array = []
    if typeof(value) != TYPE_ARRAY:
        return result
    for item in value:
        var index := int(item)
        if index >= 0 and index < puzzle_engine.puzzles.size() and not result.has(index):
            result.append(index)
    result.sort()
    return result

func get_level_count() -> int:
    return 0 if puzzle_engine == null else puzzle_engine.puzzles.size()

func is_unlocked(index: int) -> bool:
    if index < 0 or index >= get_level_count():
        return false
    if index == 0:
        return true
    return completed_levels.has(index - 1)

func is_completed(index: int) -> bool:
    return completed_levels.has(index)

func mark_completed(index: int) -> void:
    if index < 0 or index >= get_level_count():
        return
    if not completed_levels.has(index):
        completed_levels.append(index)
        completed_levels.sort()
    if index + 1 < get_level_count():
        current_level = max(current_level, index + 1)

func set_current_level(index: int) -> bool:
    if not is_unlocked(index):
        return false
    current_level = index
    return true

func get_current_level() -> int:
    return current_level

func get_progress_count() -> int:
    return completed_levels.size()

func get_progress_percent() -> float:
    var count := get_level_count()
    if count == 0:
        return 0.0
    return float(completed_levels.size()) / float(count) * 100.0

func to_save_dict() -> Dictionary:
    return {
        "current_level": current_level,
        "completed_levels": completed_levels.duplicate()
    }
