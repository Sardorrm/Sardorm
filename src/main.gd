extends Node2D

var engine := PuzzleEngine.new()
var current_index := 0
var question_label: Label
var progress_label: Label
var answer_input: LineEdit
var feedback_label: Label
var hint_label: Label
var action_button: Button

func _ready() -> void:
    if not engine.load_from_file("res://data/puzzles.json"):
        push_error("Could not load puzzle data")
        return
    _build_ui()
    _show_puzzle()

func _build_ui() -> void:
    var background := ColorRect.new()
    background.color = Color("101018")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 28)
    margin.add_theme_constant_override("margin_right", 28)
    margin.add_theme_constant_override("margin_top", 40)
    margin.add_theme_constant_override("margin_bottom", 40)
    add_child(margin)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 18)
    margin.add_child(box)

    var title := Label.new()
    title.text = "MindShift"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 40)
    box.add_child(title)

    progress_label = Label.new()
    progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(progress_label)

    question_label = Label.new()
    question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    question_label.custom_minimum_size = Vector2(0, 180)
    question_label.add_theme_font_size_override("font_size", 24)
    box.add_child(question_label)

    answer_input = LineEdit.new()
    answer_input.placeholder_text = "Your answer..."
    answer_input.custom_minimum_size = Vector2(0, 64)
    answer_input.add_theme_font_size_override("font_size", 22)
    answer_input.text_submitted.connect(_on_answer_submitted)
    box.add_child(answer_input)

    action_button = Button.new()
    action_button.text = "CHECK"
    action_button.custom_minimum_size = Vector2(0, 68)
    action_button.add_theme_font_size_override("font_size", 22)
    action_button.pressed.connect(_on_check_pressed)
    box.add_child(action_button)

    var hint_button := Button.new()
    hint_button.text = "HINT"
    hint_button.custom_minimum_size = Vector2(0, 56)
    hint_button.pressed.connect(_show_hint)
    box.add_child(hint_button)

    feedback_label = Label.new()
    feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    feedback_label.add_theme_font_size_override("font_size", 20)
    box.add_child(feedback_label)

    hint_label = Label.new()
    hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(hint_label)

func _show_puzzle() -> void:
    var puzzle := engine.get_puzzle(current_index)
    if puzzle.is_empty():
        question_label.text = "All puzzles complete!"
        action_button.disabled = true
        answer_input.disabled = true
        return
    progress_label.text = "Puzzle %d / %d" % [current_index + 1, engine.puzzles.size()]
    question_label.text = puzzle.get("prompt", "")
    answer_input.text = ""
    answer_input.editable = true
    action_button.text = "CHECK"
    action_button.disabled = false
    feedback_label.text = ""
    hint_label.text = ""

func _on_answer_submitted(_value: String) -> void:
    _check_answer()

func _on_check_pressed() -> void:
    _check_answer()

func _check_answer() -> void:
    if engine.check_answer(current_index, answer_input.text):
        feedback_label.text = "✓ Correct!"
        answer_input.editable = false
        action_button.text = "NEXT"
        action_button.pressed.disconnect(_on_check_pressed)
        action_button.pressed.connect(_next_puzzle)
    else:
        feedback_label.text = "Not quite. Try again."

func _next_puzzle() -> void:
    current_index += 1
    action_button.pressed.disconnect(_next_puzzle)
    action_button.pressed.connect(_on_check_pressed)
    _show_puzzle()

func _show_hint() -> void:
    var puzzle := engine.get_puzzle(current_index)
    if not puzzle.is_empty():
        hint_label.text = "Hint: " + str(puzzle.get("hint", ""))
