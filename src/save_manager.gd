class_name SaveManager
extends RefCounted

const SAVE_PATH: String = "user://mindshift_save.json"
const SAVE_VERSION: int = 6
const SUPPORTED_LANGUAGES: Array[String] = ["uz", "ru", "en"]

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
        "settings": {"sound": true, "haptics": true, "language": "uz"}
    }

static func _normalize_completed_levels(value) -> Array:
    if typeof(value) != TYPE_ARRAY:
        return []
    var normalized: Array = []
    var seen: Dictionary = {}
    for raw_level in value:
        var level: int = int(raw_level)
        if level < 0 or seen.has(level):
            continue
        seen[level] = true
        normalized.append(level)
    normalized.sort()
    return normalized

static func _normalize_settings(value, defaults: Dictionary) -> Dictionary:
    if typeof(value) != TYPE_DICTIONARY:
        return defaults["settings"].duplicate(true)
    var settings: Dictionary = defaults["settings"].merged(value)
    var language: String = str(settings.get("language", "uz")).to_lower()
    if language not in SUPPORTED_LANGUAGES:
        language = "uz"
    settings["language"] = language
    settings["sound"] = bool(settings.get("sound", true))
    settings["haptics"] = bool(settings.get("haptics", true))
    return settings

static func migrate_data(data: Dictionary) -> Dictionary:
    var defaults: Dictionary = _defaults()
    var result: Dictionary = defaults.duplicate(true)
    var source_version: int = int(data.get("version", 1))
    result["version"] = SAVE_VERSION
    result["current_level"] = max(0, int(data.get("current_level", 0)))
    result["completed_levels"] = _normalize_completed_levels(data.get("completed_levels", data.get("completed", [])))
    result["hints_used"] = max(0, int(data.get("hints_used", 0)))
    for key in ["stats", "achievements", "daily_challenges", "streak", "lives"]:
        var value = data.get(key, {})
        if typeof(value) == TYPE_DICTIONARY:
            result[key] = value.duplicate(true)

    result["settings"] = _normalize_settings(data.get("settings", {}), defaults)
    if source_version < 5 and result["streak"].is_empty():
        result["streak"] = defaults["streak"].duplicate(true)
    if source_version < 4 and result["lives"].is_empty():
        result["lives"] = defaults["lives"].duplicate(true)
    return result

static func load_progress() -> Dictionary:
    var defaults: Dictionary = _defaults()
    if not FileAccess.file_exists(SAVE_PATH):
        return defaults
    var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return defaults
    var data = JSON.parse_string(file.get_as_text())
    if typeof(data) != TYPE_DICTIONARY:
        return defaults
    return migrate_data(data)

static func save_progress(current_level: int, completed_levels: Array, hints_used: int, stats: Dictionary = {}, achievements: Dictionary = {}, settings: Dictionary = {}, daily_challenges: Dictionary = {}, lives: Dictionary = {}, streak: Dictionary = {}) -> bool:
    var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return false
    var defaults: Dictionary = _defaults()
    var data: Dictionary = {
        "version": SAVE_VERSION,
        "current_level": max(0, current_level),
        "completed_levels": _normalize_completed_levels(completed_levels),
        "hints_used": max(0, hints_used),
        "stats": stats.duplicate(true),
        "achievements": achievements.duplicate(true),
        "daily_challenges": daily_challenges.duplicate(true),
        "streak": streak.duplicate(true) if not streak.is_empty() else defaults["streak"],
        "lives": lives.duplicate(true) if not lives.is_empty() else defaults["lives"],
        "settings": _normalize_settings(settings, defaults)
    }
    file.store_string(JSON.stringify(data))
    return file.get_error() == OK

static func clear_progress() -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        return true
    return DirAccess.remove_absolute(SAVE_PATH) == OK
