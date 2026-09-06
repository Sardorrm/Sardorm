class_name StatsManager
extends RefCounted

var solved := 0
var failed := 0
var hints := 0
var total_time_seconds := 0.0
var solved_time_seconds := 0.0
var attempt_counted_time_seconds := 0.0
var category_stats: Dictionary = {}

func load_from_dict(data: Dictionary) -> void:
    solved = max(0, int(data.get("solved", 0)))
    failed = max(0, int(data.get("failed", 0)))
    hints = max(0, int(data.get("hints", data.get("hints_used", 0))))
    total_time_seconds = max(0.0, float(data.get("total_time_seconds", 0.0)))
    solved_time_seconds = max(0.0, float(data.get("solved_time_seconds", 0.0)))
    attempt_counted_time_seconds = max(0.0, float(data.get("attempt_counted_time_seconds", total_time_seconds)))
    var categories = data.get("category_stats", {})
    category_stats = categories.duplicate(true) if typeof(categories) == TYPE_DICTIONARY else {}

func record_solved(seconds: float, category: String = "") -> void:
    var elapsed := max(seconds, 0.0)
    solved += 1
    total_time_seconds += elapsed
    solved_time_seconds += elapsed
    attempt_counted_time_seconds += elapsed
    _record_category(category, true, elapsed)

func record_failed(category: String = "", seconds: float = 0.0) -> void:
    var elapsed := max(seconds, 0.0)
    failed += 1
    total_time_seconds += elapsed
    attempt_counted_time_seconds += elapsed
    _record_category(category, false, elapsed)

func record_hint(category: String = "") -> void:
    hints += 1
    if not category.is_empty():
        var stats: Dictionary = category_stats.get(category, {"solved": 0, "failed": 0, "hints": 0, "time": 0.0})
        stats["hints"] = int(stats.get("hints", 0)) + 1
        category_stats[category] = stats

func _record_category(category: String, correct: bool, seconds: float) -> void:
    if category.is_empty():
        return
    var stats: Dictionary = category_stats.get(category, {"solved": 0, "failed": 0, "hints": 0, "time": 0.0})
    stats["solved"] = int(stats.get("solved", 0)) + (1 if correct else 0)
    stats["failed"] = int(stats.get("failed", 0)) + (0 if correct else 1)
    stats["time"] = float(stats.get("time", 0.0)) + max(seconds, 0.0)
    category_stats[category] = stats

func get_accuracy() -> float:
    var attempts := solved + failed
    return 0.0 if attempts == 0 else float(solved) / float(attempts) * 100.0

func get_average_time() -> float:
    var attempts := solved + failed
    return 0.0 if attempts == 0 else attempt_counted_time_seconds / float(attempts)

func get_profile() -> Dictionary:
    if solved + failed == 0:
        return {"name": "Yangi fikrlovchi", "score": 0.0}
    var accuracy_score := get_accuracy()
    var speed_score := clamp(100.0 - get_average_time() * 2.0, 0.0, 100.0)
    var score := accuracy_score * 0.7 + speed_score * 0.3
    var name := "Analitik"
    if score >= 85.0:
        name = "MindShift Master"
    elif score >= 70.0:
        name = "Strateg"
    elif score >= 50.0:
        name = "Izlanuvchi"
    return {"name": name, "score": score}

func to_dict() -> Dictionary:
    return {
        "solved": solved,
        "failed": failed,
        "hints": hints,
        "total_time_seconds": total_time_seconds,
        "solved_time_seconds": solved_time_seconds,
        "attempt_counted_time_seconds": attempt_counted_time_seconds,
        "category_stats": category_stats.duplicate(true)
    }
