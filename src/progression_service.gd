class_name ProgressionService
extends RefCounted

signal progression_changed
signal achievement_unlocked(achievement_id: String)

var level_manager: LevelManager
var stats_manager: StatsManager
var achievement_manager: AchievementManager
var event_tracker: EventTracker

func setup(levels: LevelManager, stats: StatsManager, achievements: AchievementManager, events: EventTracker) -> void:
    level_manager = levels
    stats_manager = stats
    achievement_manager = achievements
    event_tracker = events

func record_hint(puzzle: PuzzleDefinition) -> void:
    if stats_manager == null or puzzle == null:
        return
    stats_manager.record_hint(puzzle.category)
    if event_tracker != null:
        event_tracker.record(EventTracker.HINT_USED, {"puzzle_id": puzzle.id, "category": puzzle.category})
    progression_changed.emit()

func record_attempt(puzzle: PuzzleDefinition, correct: bool, elapsed: float, attempts: int, hint_used: bool) -> PuzzleResult:
    var result := PuzzleResult.new()
    result.configure(puzzle, correct, elapsed, attempts, hint_used)
    if puzzle == null or stats_manager == null:
        return result

    if correct:
        stats_manager.record_solved(elapsed, puzzle.category)
        if level_manager != null:
            var level_index := _find_level_index(puzzle.id)
            if level_index >= 0:
                level_manager.mark_completed(level_index)
        if achievement_manager != null:
            result.newly_unlocked = achievement_manager.on_solved(stats_manager.solved, hint_used)
            for achievement_id in result.newly_unlocked:
                achievement_unlocked.emit(achievement_id)
        if event_tracker != null:
            event_tracker.record(EventTracker.LEVEL_SOLVED, result.to_dict())
    else:
        stats_manager.record_failed(puzzle.category)
        if achievement_manager != null:
            achievement_manager.on_failed()
        if event_tracker != null:
            event_tracker.record(EventTracker.LEVEL_FAILED, {
                "puzzle_id": puzzle.id,
                "attempts": attempts,
                "elapsed_seconds": elapsed
            })

    progression_changed.emit()
    return result

func _find_level_index(puzzle_id: String) -> int:
    if level_manager == null or level_manager.puzzle_engine == null:
        return -1
    for index in range(level_manager.puzzle_engine.puzzles.size()):
        if level_manager.puzzle_engine.puzzles[index].get("id", "") == puzzle_id:
            return index
    return -1

func to_save_dict() -> Dictionary:
    return {
        "stats": stats_manager.to_dict() if stats_manager != null else {},
        "achievements": achievement_manager.to_dict() if achievement_manager != null else {}
    }
