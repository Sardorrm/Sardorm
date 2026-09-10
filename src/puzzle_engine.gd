class_name PuzzleEngine
extends RefCounted

const EXTRA_PATH_SUFFIX := "_extra.json"
const ALLOWED_ANSWER_TYPES := ["text", "number", "choice", "true_false"]

var puzzles: Array = []
var last_error: String = ""

func load_from_file(path: String) -> bool:
    last_error = ""
    var incoming: Array = []
    if not _read_puzzles(path, incoming):
        puzzles.clear()
        return false
    var extra_path := path.get_basename() + EXTRA_PATH_SUFFIX
    if FileAccess.file_exists(extra_path):
        var extra: Array = []
        if not _read_puzzles(extra_path, extra):
            puzzles.clear()
            return false
        incoming.append_array(extra)
    var ids: Dictionary = {}
    for puzzle in incoming:
        var id := str(puzzle["id"])
        if ids.has(id):
            last_error = "Invalid or duplicate puzzle id: " + id
            puzzles.clear()
            return false
        ids[id] = true
    puzzles = incoming
    return true

func _read_puzzles(path: String, target: Array) -> bool:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        last_error = "File not found: " + path
        return false
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY or typeof(parsed.get("puzzles")) != TYPE_ARRAY:
        last_error = "Invalid puzzle document: " + path
        return false
    for puzzle in parsed["puzzles"]:
        if typeof(puzzle) != TYPE_DICTIONARY:
            last_error = "Puzzle is not an object"
            return false
        for field in ["id", "category", "difficulty", "prompt", "answer", "hint", "explanation"]:
            if not puzzle.has(field):
                last_error = "Missing field: " + field
                return false
        var id := str(puzzle["id"])
        if id.is_empty():
            last_error = "Empty puzzle id"
            return false
        var difficulty := int(puzzle["difficulty"])
        if difficulty < 1 or difficulty > 5:
            last_error = "Difficulty must be 1..5 for " + id
            return false
        if str(puzzle["prompt"]).strip_edges().is_empty():
            last_error = "Empty prompt for " + id
            return false
        if str(puzzle["hint"]).strip_edges().is_empty():
            last_error = "Empty hint for " + id
            return false
        if str(puzzle["explanation"]).strip_edges().is_empty():
            last_error = "Empty explanation for " + id
            return false
        if puzzle.has("answers") and typeof(puzzle["answers"]) == TYPE_ARRAY and puzzle["answers"].is_empty():
            last_error = "answers cannot be empty for " + id
            return false
        var answer_type := str(puzzle.get("answer_type", "number" if (puzzle["answer"] is int or puzzle["answer"] is float) else "text"))
        if not ALLOWED_ANSWER_TYPES.has(answer_type):
            last_error = "Invalid answer_type for " + id + ": " + answer_type
            return false
        if answer_type == "true_false":
            if not puzzle.has("answers") or typeof(puzzle["answers"]) != TYPE_ARRAY or puzzle["answers"].size() != 2:
                last_error = "true_false requires exactly two answers for " + id
                return false
        if answer_type == "choice":
            if not puzzle.has("answers") or typeof(puzzle["answers"]) != TYPE_ARRAY or puzzle["answers"].size() < 2:
                last_error = "choice requires at least two answers for " + id
                return false
        if puzzle.has("answers") and typeof(puzzle["answers"]) == TYPE_ARRAY:
            var normalized_answers: Array = []
            for candidate in puzzle["answers"]:
                var normalized := str(candidate).strip_edges().to_lower()
                if normalized.is_empty():
                    last_error = "answers cannot contain empty values for " + id
                    return false
                if normalized_answers.has(normalized):
                    last_error = "Duplicate accepted answer for " + id
                    return false
                normalized_answers.append(normalized)
            if not normalized_answers.has(str(puzzle["answer"]).strip_edges().to_lower()):
                last_error = "answer must be included in answers for " + id
                return false
        target.append(puzzle)
    return true

func get_puzzle(index: int) -> Dictionary:
    if index < 0 or index >= puzzles.size():
        return {}
    return puzzles[index]

func get_categories() -> Array:
    var result: Array = []
    var seen: Dictionary = {}
    for puzzle in puzzles:
        var category := str(puzzle.get("category", ""))
        if not category.is_empty() and not seen.has(category):
            seen[category] = true
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
    var actual_text := _normalize(actual)
    if expected is int or expected is float:
        var parsed = actual_text.to_float()
        return is_finite(parsed) and abs(parsed - float(expected)) < 0.0001
    return _normalize(str(expected)) == actual_text

func _normalize(value: String) -> String:
    var text := value.strip_edges().to_lower()
    while text.contains("  "):
        text = text.replace("  ", " ")
    return text
