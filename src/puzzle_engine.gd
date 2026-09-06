class_name PuzzleEngine
extends RefCounted

var puzzles: Array = []
var last_error: String = ""

func load_from_file(path: String) -> bool:
    last_error = ""
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        last_error = "File not found: " + path
        return false
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY or typeof(parsed.get("puzzles")) != TYPE_ARRAY:
        last_error = "Invalid puzzle document"
        return false
    var incoming: Array = parsed["puzzles"]
    var ids: Dictionary = {}
    for puzzle in incoming:
        if typeof(puzzle) != TYPE_DICTIONARY:
            last_error = "Puzzle is not an object"
            return false
        for field in ["id", "category", "difficulty", "prompt", "answer", "hint"]:
            if not puzzle.has(field):
                last_error = "Missing field: " + field
                return false
        var id := str(puzzle["id"])
        if id.is_empty() or ids.has(id):
            last_error = "Invalid or duplicate puzzle id: " + id
            return false
        if int(puzzle["difficulty"]) < 1:
            last_error = "Invalid difficulty for " + id
            return false
        if str(puzzle["prompt"]).strip_edges().is_empty():
            last_error = "Empty prompt for " + id
            return false
        ids[id] = true
    puzzles = incoming
    return true

func get_puzzle(index: int) -> Dictionary:
    if index < 0 or index >= puzzles.size():
        return {}
    return puzzles[index]

func get_categories() -> Array:
    var result: Array = []
    for puzzle in puzzles:
        var category := str(puzzle.get("category", ""))
        if not category.is_empty() and not result.has(category):
            result.append(category)
    return result

func check_answer(index: int, answer: String) -> bool:
    var puzzle := get_puzzle(index)
    if puzzle.is_empty():
        return false
    var candidates: Array = []
    if puzzle.has("answers") and typeof(puzzle["answers"]) == TYPE_ARRAY:
        candidates = puzzle["answers"]
    else:
        candidates = [puzzle.get("answer", "")]
    for expected in candidates:
        if _answers_match(expected, answer):
            return true
    return false

func _answers_match(expected, actual: String) -> bool:
    var expected_text := _normalize(str(expected))
    var actual_text := _normalize(actual)
    if expected is int or expected is float:
        var parsed = actual_text.to_float()
        return is_finite(parsed) and abs(parsed - float(expected)) < 0.0001
    return expected_text == actual_text

func _normalize(value: String) -> String:
    var text := value.strip_edges().to_lower()
    while text.contains("  "):
        text = text.replace("  ", " ")
    return text
