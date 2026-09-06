class_name SaveManager
extends RefCounted

const SAVE_PATH := "user://mindshift_save.json"
const SAVE_VERSION := 1

static func load_progress() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return {"version": SAVE_VERSION, "current_level": 0, "completed": [], "hints_used": 0}
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return {"version": SAVE_VERSION, "current_level": 0, "completed": [], "hints_used": 0}
    var data = JSON.parse_string(file.get_as_text())
    if typeof(data) != TYPE_DICTIONARY:
        return {"version": SAVE_VERSION, "current_level": 0, "completed": [], "hints_used": 0}
    data["version"] = int(data.get("version", SAVE_VERSION))
    return data

static func save_progress(current_level: int, completed: Array, hints_used: int) -> bool:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return false
    var data := {"version": SAVE_VERSION, "current_level": current_level, "completed": completed, "hints_used": hints_used}
    file.store_string(JSON.stringify(data))
    return true
