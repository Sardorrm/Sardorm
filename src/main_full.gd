extends Node2D

var engine := PuzzleEngine.new()
var stats := StatsManager.new()
var current_index := 0
var completed: Array = []
var hints_used := 0
var level_started_at := 0
var question_label: Label
var progress_label: Label
var feedback_label: Label
var answer_input: LineEdit
var hint_label: Label
var hint_button: Button
var submit_button: Button
var next_button: Button
var content_box: VBoxContainer

func _ready() -> void:
    engine.load_from_file("res://data/puzzles.json")
    var save := SaveManager.load_progress()
    current_index = clampi(int(save.get("current_level", 0)), 0, max(engine.puzzles.size() - 1, 0))
    completed = save.get("completed", [])
    hints_used = int(save.get("hints_used", 0))
    _build_ui()
    _show_home()

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
    content_box = VBoxContainer.new()
    content_box.add_theme_constant_override("separation", 18)
    margin.add_child(content_box)

func _clear_ui() -> void:
    for child in content_box.get_children():
        child.queue_free()

func _label(text: String, size: int = 20) -> Label:
    var label := Label.new()
    label.text = text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", size)
    return label

func _button(text: String, callback: Callable) -> Button:
    var button := Button.new()
    button.text = text
    button.custom_minimum_size = Vector2(0, 64)
    button.add_theme_font_size_override("font_size", 20)
    button.pressed.connect(callback)
    return button

func _show_home() -> void:
    _clear_ui()
    content_box.add_child(_label("MindShift", 44))
    content_box.add_child(_label("Don't just find the answer — change the way you think.", 18))
    content_box.add_child(_label("Levels: %d   Solved: %d" % [engine.puzzles.size(), completed.size()], 16))
    content_box.add_child(_button("START", _start_game))

func _start_game() -> void:
    if engine.puzzles.is_empty():
        content_box.add_child(_label("No puzzles available."))
        return
    _show_puzzle()

func _show_puzzle() -> void:
    _clear_ui()
    var puzzle: Dictionary = engine.get_puzzle(current_index)
    level_started_at = Time.get_ticks_msec()
    progress_label = _label("LEVEL %d / %d • %s" % [current_index + 1, engine.puzzles.size(), str(puzzle.get("difficulty", ""))], 16)
    content_box.add_child(progress_label)
    content_box.add_child(_label(str(puzzle.get("category", "")).to_upper(), 15))
    question_label = _label(str(puzzle.get("prompt", "")), 25)
    question_label.custom_minimum_size = Vector2(0, 180)
    question_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    content_box.add_child(question_label)
    answer_input = LineEdit.new()
    answer_input.placeholder_text = "Your answer"
    answer_input.custom_minimum_size = Vector2(0, 64)
    answer_input.add_theme_font_size_override("font_size", 20)
    answer_input.text_submitted.connect(_on_answer_submitted)
    content_box.add_child(answer_input)
    submit_button = _button("CHECK ANSWER", _check_answer)
    content_box.add_child(submit_button)
    hint_button = _button("HINT", _show_hint)
    content_box.add_child(hint_button)
    hint_label = _label("", 17)
    content_box.add_child(hint_label)
    feedback_label = _label("", 19)
    content_box.add_child(feedback_label)
    next_button = _button("NEXT LEVEL", _next_level)
    next_button.visible = false
    content_box.add_child(next_button)
    content_box.add_child(_button("MENU", _show_home))
    answer_input.grab_focus()

func _on_answer_submitted(_text: String) -> void:
    _check_answer()

func _check_answer() -> void:
    if answer_input.text.strip_edges().is_empty():
        feedback_label.text = "Enter an answer first."
        return
    if engine.check_answer(current_index, answer_input.text):
        var id := str(engine.get_puzzle(current_index).get("id", current_index + 1))
        if not completed.has(id):
            completed.append(id)
        stats.record_solved(float(Time.get_ticks_msec() - level_started_at) / 1000.0)
        feedback_label.text = "✓ Correct! Your thinking shifted."
        answer_input.editable = false
        submit_button.disabled = true
        hint_button.disabled = true
        next_button.visible = true
        _save()
    else:
        stats.record_failed()
        feedback_label.text = "✗ Not quite. Try a different way of thinking."

func _show_hint() -> void:
    hint_label.text = "Hint: " + str(engine.get_puzzle(current_index).get("hint", "Look at the problem differently."))
    hints_used += 1
    stats.record_hint()
    _save()

func _next_level() -> void:
    if current_index < engine.puzzles.size() - 1:
        current_index += 1
        _save()
        _show_puzzle()
    else:
        _show_complete()

func _show_complete() -> void:
    _clear_ui()
    content_box.add_child(_label("MindShift Complete", 36))
    content_box.add_child(_label("You finished all available levels.", 21))
    content_box.add_child(_label("Solved: %d / %d" % [completed.size(), engine.puzzles.size()], 19))
    content_box.add_child(_button("PLAY AGAIN", func():
        current_index = 0
        _show_puzzle()
    ))
    content_box.add_child(_button("MENU", _show_home))

func _save() -> void:
    SaveManager.save_progress(current_index, completed, hints_used)
