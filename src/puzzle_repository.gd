class_name PuzzleRepository
extends RefCounted

const SUPPORTED_ANSWER_TYPES := ["text", "number", "choice", "true_false"]
const EXTRA_PATH_SUFFIX := "_extra.json"

var puzzles: Array[PuzzleDefinition] = []
var by_id: Dictionary = {}
var last_error: String = ""

func load_from_file(path: String) -> bool:
    last_error = ""
    puzzles.clear()
    by_id.clear()
    var paths := [path]
    var extra_path := path.get_basename() + EXTRA_PATH_SUFFIX
    if FileAccess.file_exists(extra_path):
        paths.append(extra_path)
    for source_path in paths:
        if not _load_document(source_path):
            puzzles.clear()
            by_id.clear()
            return false
    return true

func _load_document(path: String) -> bool:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        last_error = "File not found: " + path
        return false
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY or typeof(parsed.get("puzzles")) != TYPE_ARRAY:
        last_error = "Invalid puzzle document: " + path
        return false
    for raw in parsed["puzzles"]:
        if typeof(raw) != TYPE_DICTIONARY:
            last_error = "Puzzle is not an object"
            return false
        var puzzle := PuzzleDefinition.from_dict(raw)
        if not _validate(puzzle):
            return false
        puzzles.append(puzzle)
        by_id[puzzle.id] = puzzle
    return true

func get_by_index(index: int) -> PuzzleDefinition:
    if index < 0 or index >= puzzles.size():
        return null
    return puzzles[index]

func get_by_id(id: String) -> PuzzleDefinition:
    return by_id.get(id)

func get_category(category: String) -> Array[PuzzleDefinition]:
    var result: Array[PuzzleDefinition] = []
    for puzzle in puzzles:
        if puzzle.category == category:
            result.append(puzzle)
    return result

func get_count() -> int:
    return puzzles.size()

func _validate(puzzle: PuzzleDefinition) -> bool:
    if puzzle.id.is_empty() or by_id.has(puzzle.id):
        last_error = "Invalid or duplicate puzzle id: " + puzzle.id
        return false
    if puzzle.category.is_empty():
        last_error = "Empty category for " + puzzle.id
        return false
    if puzzle.difficulty < 1 or puzzle.difficulty > 5:
        last_error = "Difficulty must be 1..5 for " + puzzle.id
        return false
    if puzzle.prompt.strip_edges().is_empty():
        last_error = "Empty prompt for " + puzzle.id
        return false
    if puzzle.hint.strip_edges().is_empty():
        last_error = "Empty hint for " + puzzle.id
        return false
    if puzzle.get_answers().is_empty():
        last_error = "No answer for " + puzzle.id
        return false
    if puzzle.answer_type not in SUPPORTED_ANSWER_TYPES:
        last_error = "Unsupported answer_type for " + puzzle.id
        return false
    if puzzle.answer_type in ["choice", "true_false"] and puzzle.answers.is_empty():
        last_error = "Choice/true_false puzzle requires answers for " + puzzle.id
        return false
    if puzzle.answer_type == "true_false":
        for option in puzzle.answers:
            if str(option).to_lower() not in ["true", "false"]:
                last_error = "true_false options must be true/false for " + puzzle.id
                return false
    return true
