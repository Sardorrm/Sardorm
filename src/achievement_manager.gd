class_name AchievementManager
extends RefCounted

const DEFINITIONS := [
    {"id": "first_step", "name": "Birinchi qadam", "description": "Birinchi puzzleni yeching."},
    {"id": "ten_solved", "name": "10 ta fikr", "description": "10 ta puzzleni yeching."},
    {"id": "perfect_run", "name": "Toza fikr", "description": "5 ta ketma-ket xatosiz yechim."},
    {"id": "no_hint", "name": "O‘zing topding", "description": "10 ta puzzleni hintsiz yeching."},
    {"id": "master", "name": "MindShift Master", "description": "100 ta puzzleni yeching."}
]

var unlocked: Array = []
var streak := 0
var hints_free_solved := 0

func load_from_dict(data: Dictionary) -> void:
    unlocked = data.get("unlocked", []).duplicate()
    streak = int(data.get("streak", 0))
    hints_free_solved = int(data.get("hints_free_solved", 0))

func on_solved(total_solved: int, hint_used: bool) -> Array:
    streak += 1
    if not hint_used:
        hints_free_solved += 1
    var newly: Array = []
    if total_solved >= 1:
        _unlock("first_step", newly)
    if total_solved >= 10:
        _unlock("ten_solved", newly)
    if streak >= 5:
        _unlock("perfect_run", newly)
    if hints_free_solved >= 10:
        _unlock("no_hint", newly)
    if total_solved >= 100:
        _unlock("master", newly)
    return newly

func on_failed() -> void:
    streak = 0

func _unlock(id: String, newly: Array) -> void:
    if not unlocked.has(id):
        unlocked.append(id)
        newly.append(id)

func to_dict() -> Dictionary:
    return {"unlocked": unlocked.duplicate(), "streak": streak, "hints_free_solved": hints_free_solved}
