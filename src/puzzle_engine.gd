class_name PuzzleEngine
extends RefCounted

var puzzles: Array = []

func load_from_file(path: String) -> bool:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return false
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("puzzles"):
        return false
    puzzles = parsed["puzzles"]
    return true

func get_puzzle(index: int) -> Dictionary:
    if index < 0 or index >= puzzles.size():
        return {}
    return puzzles[index]

func check_answer(index: int, answer: String) -> bool:
    var puzzle := get_puzzle(index)
    if puzzle.is_empty():
        return false
    var expected = puzzle.get("answer")
    return _normalize(str(expected)) == _normalize(answer)

func _normalize(value: String) -> String:
    return value.strip_edges().to_lower().replace("  ", " ")
