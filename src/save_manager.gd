class_name SaveManager
extends RefCounted

const SAVE_PATH := "user://mindshift_save.json"
const SAVE_VERSION := 6

static func _defaults() -> Dictionary:
    return {
        "version": SAVE_VERSION,
        "current_level": 0,
        "completed_levels": [],
        "hints_used": 0,
        "stats": {},
        "achievements": {},
        "daily_challenges": {},
        "streak": {"current_streak": 0, "best_streak": 0, "last_completed_date": ""},
        "lives": {"lives": 3, "last_loss_unix": 0},
        "settings": {"sound": true, "haptics": true}
    }

static func load_progress() -> Dictionary:
    var defaults := _defaults()
    if not FileAccess.file_exists(SAVE_PATH):
        return defaults
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return defaults
    var data = JSON.parse_string(file.get_as_text())
    if typeof(data) != TYPE_DICTIONARY:
        return defaults
    var result := defaults.duplicate(true)
    var source_version := int(data.get("version", 1))
    result["version"] = SAVE_VERSION
    result["current_level"] = max(0, int(data.get("current_level", 0)))
    var completed = data.get("completed_levels", data.get("completed", []))
    if typeof(completed) == TYPE_ARRAY:
        result["completed_levels"] = completed.duplicate()
    result["hints_used"] = max(0, int(data.get("hints_used", 0)))
    for key in ["stats", "achievements", "daily_challenges", "streak", "lives"]:
        var value = data.get(key, {})
        if typeof(value) == TYPE_DICTIONARY:
            result[key] = value.duplicate(true)
    var settings = data.get("settings", {})
    if typeof(settings) == TYPE_DICTIONARY:
        result["settings"] = defaults["settings"].merged(settings)

    # v5 and earlier saves remain readable; missing newer fields receive defaults.
    if source_version < 5 and result["streak"].is_empty():
        result["streak"] = defaults["streak"].duplicate(true)
    if source_version < 4 and result["lives"].is_empty():
        result["lives"] = defaults["lives"].duplicate(true)
    return result

static func save_progress(current_level: int, completed_levels: Array, hints_used: int, stats: Dictionary = {}, achievements: Dictionary = {}, settings: Dictionary = {}, daily_challenges: Dictionary = {}, lives: Dictionary = {}, streak: Dictionary = {}) -> bool:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return false
    var defaults := _defaults()
    var data := {
        "version": SAVE_VERSION,
        "current_level": max(0, current_level),
        "completed_levels": completed_levels.duplicate(),
        "hints_used": max(0, hints_used),
        "stats": stats.duplicate(true),
        "achievements": achievements.duplicate(true),
        "daily_challenges": daily_challenges.duplicate(true),
        "streak": streak.duplicate(true) if not streak.is_empty() else defaults["streak"],
        "lives": lives.duplicate(true) if not lives.is_empty() else defaults["lives"],
        "settings": defaults["settings"].merged(settings)
    }
    file.store_string(JSON.stringify(data))
    return file.get_error() == OK

static func clear_progress() -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        return true
    return DirAccess.remove_absolute(SAVE_PATH) == OK
