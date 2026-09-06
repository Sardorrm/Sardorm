class_name EventTracker
extends RefCounted

signal event_recorded(name: String, payload: Dictionary)

const APP_STARTED := "app_started"
const LEVEL_STARTED := "level_started"
const ANSWER_SUBMITTED := "answer_submitted"
const LEVEL_SOLVED := "level_solved"
const LEVEL_FAILED := "level_failed"
const HINT_USED := "hint_used"
const LEVEL_SELECTED := "level_selected"
const PROGRESS_RESET := "progress_reset"

var enabled := true
var history: Array = []

func record(name: String, payload: Dictionary = {}) -> void:
    if not enabled or name.strip_edges().is_empty():
        return
    var event := {
        "name": name,
        "timestamp_unix": Time.get_unix_time_from_system(),
        "payload": payload.duplicate(true)
    }
    history.append(event)
    event_recorded.emit(name, payload)

func drain() -> Array:
    var result := history.duplicate(true)
    history.clear()
    return result

func clear() -> void:
    history.clear()
