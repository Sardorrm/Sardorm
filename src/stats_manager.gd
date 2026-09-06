class_name StatsManager
extends RefCounted

var solved := 0
var failed := 0
var hints := 0
var total_time_seconds := 0.0

func record_solved(seconds: float) -> void:
    solved += 1
    total_time_seconds += max(seconds, 0.0)

func record_failed() -> void:
    failed += 1

func record_hint() -> void:
    hints += 1

func to_dict() -> Dictionary:
    return {"solved": solved, "failed": failed, "hints": hints, "total_time_seconds": total_time_seconds}
