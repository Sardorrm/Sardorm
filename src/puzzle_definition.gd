class_name PuzzleDefinition
extends RefCounted

var id: String
var category: String
var difficulty: int
var prompt: String
var hint: String
var explanation: String
var answer
var answers: Array = []
var answer_type: String
var time_limit_seconds: float
var tags: Array = []

static func from_dict(data: Dictionary) -> PuzzleDefinition:
    var puzzle: PuzzleDefinition = PuzzleDefinition.new()
    puzzle.id = str(data.get("id", "")).strip_edges()
    puzzle.category = str(data.get("category", "")).strip_edges().to_lower()
    puzzle.difficulty = int(data.get("difficulty", 0))
    puzzle.prompt = str(data.get("prompt", ""))
    puzzle.hint = str(data.get("hint", ""))
    puzzle.explanation = str(data.get("explanation", ""))
    puzzle.answer = data.get("answer", "")
    var raw_answers = data.get("answers", [])
    if typeof(raw_answers) == TYPE_ARRAY:
        puzzle.answers = raw_answers.duplicate()
    var raw_type = data.get("answer_type", _infer_answer_type(puzzle.answer))
    puzzle.answer_type = str(raw_type).strip_edges().to_lower()
    puzzle.time_limit_seconds = maxf(0.0, float(data.get("time_limit_seconds", 0.0)))
    var raw_tags = data.get("tags", [])
    if typeof(raw_tags) == TYPE_ARRAY:
        puzzle.tags = raw_tags.duplicate()
    return puzzle

func get_answers() -> Array:
    if not answers.is_empty():
        return answers
    return [answer]

func is_timed() -> bool:
    return time_limit_seconds > 0.0

func has_explanation() -> bool:
    return not explanation.strip_edges().is_empty()

func to_dict() -> Dictionary:
    var result: Dictionary = {
        "id": id,
        "category": category,
        "difficulty": difficulty,
        "prompt": prompt,
        "answer": answer,
        "hint": hint,
        "answer_type": answer_type
    }
    if has_explanation():
        result["explanation"] = explanation
    if not answers.is_empty():
        result["answers"] = answers.duplicate()
    if time_limit_seconds > 0.0:
        result["time_limit_seconds"] = time_limit_seconds
    if not tags.is_empty():
        result["tags"] = tags.duplicate()
    return result

static func _infer_answer_type(value) -> String:
    if value is int or value is float:
        return "number"
    return "text"
