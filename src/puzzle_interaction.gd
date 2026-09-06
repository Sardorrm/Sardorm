class_name PuzzleInteraction
extends RefCounted

const TYPE_TEXT := "text"
const TYPE_NUMBER := "number"
const TYPE_CHOICE := "choice"
const TYPE_TRUE_FALSE := "true_false"

static func input_type(puzzle: PuzzleDefinition) -> String:
    if puzzle == null:
        return TYPE_TEXT
    return puzzle.answer_type if puzzle.answer_type in [TYPE_TEXT, TYPE_NUMBER, TYPE_CHOICE, TYPE_TRUE_FALSE] else TYPE_TEXT

static func needs_line_edit(puzzle: PuzzleDefinition) -> bool:
    return input_type(puzzle) in [TYPE_TEXT, TYPE_NUMBER]

static func choices(puzzle: PuzzleDefinition) -> Array:
    if puzzle == null:
        return []
    return puzzle.answers.duplicate() if not puzzle.answers.is_empty() else []

static func validate_selection(puzzle: PuzzleDefinition, value: String) -> bool:
    if puzzle == null:
        return false
    var selected := value.strip_edges()
    for expected in puzzle.get_answers():
        if str(expected).strip_edges().to_lower() == selected.to_lower():
            return true
    return false
