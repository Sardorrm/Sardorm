class_name AnswerInputFactory
extends RefCounted

const TYPE_TEXT := "text"
const TYPE_NUMBER := "number"
const TYPE_CHOICE := "choice"
const TYPE_TRUE_FALSE := "true_false"

static func normalize_type(puzzle: PuzzleDefinition) -> String:
    if puzzle == null:
        return TYPE_TEXT
    if puzzle.answer_type in [TYPE_TEXT, TYPE_NUMBER, TYPE_CHOICE, TYPE_TRUE_FALSE]:
        return puzzle.answer_type
    return TYPE_TEXT

static func is_button_input(puzzle: PuzzleDefinition) -> bool:
    var kind := normalize_type(puzzle)
    return kind == TYPE_CHOICE or kind == TYPE_TRUE_FALSE

static func is_numeric(puzzle: PuzzleDefinition) -> bool:
    return normalize_type(puzzle) == TYPE_NUMBER

static func button_labels(puzzle: PuzzleDefinition) -> Array:
    if puzzle == null:
        return []
    if normalize_type(puzzle) == TYPE_TRUE_FALSE:
        return ["To‘g‘ri", "Noto‘g‘ri"]
    return puzzle.answers.duplicate() if not puzzle.answers.is_empty() else []

static func validate(puzzle: PuzzleDefinition, value: String) -> bool:
    return PuzzleInteraction.validate_selection(puzzle, value)
