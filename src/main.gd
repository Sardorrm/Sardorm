extends Node2D

var engine := PuzzleEngine.new()
var level_manager := LevelManager.new()
var stats := StatsManager.new()
var current_index := 0
var puzzle_started_at := 0
var hint_used_this_level := false

var question_label: Label
var progress_label: Label
var answer_input: LineEdit
var feedback_label: Label
var hint_label: Label
var action_button: Button
var hint_button: Button
var stats_label: Label

func _ready() -> void:
    if not engine.load_from_file("res://data/puzzles.json"):
        push_error("Could not load puzzle data")
        return
    var save_data := SaveManager.load_progress()
    stats.load_from_dict(save_data.get("stats", {}))
    level_manager.setup(engine, save_data)
    current_index = level_manager.get_current_level()
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
    box.add_theme_constant_override("separation", 14)
    margin.add_child(box)

    var title := Label.new()
    title.text = "MindShift"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 40)
    box.add_child(title)

    progress_label = Label.new()
    progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    progress_label.add_theme_font_size_override("font_size", 18)
    box.add_child(progress_label)

    question_label = Label.new()
    question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    question_label.custom_minimum_size = Vector2(0, 220)
    question_label.add_theme_font_size_override("font_size", 24)
    box.add_child(question_label)

    answer_input = LineEdit.new()
    answer_input.placeholder_text = "Javobingiz..."
    answer_input.custom_minimum_size = Vector2(0, 64)
    answer_input.add_theme_font_size_override("font_size", 22)
    answer_input.text_submitted.connect(_on_answer_submitted)
    box.add_child(answer_input)

    action_button = Button.new()
    action_button.text = "TEKSHIRISH"
    action_button.custom_minimum_size = Vector2(0, 68)
    action_button.add_theme_font_size_override("font_size", 22)
    action_button.pressed.connect(_on_action_pressed)
    box.add_child(action_button)

    hint_button = Button.new()
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

    stats_label = Label.new()
    stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(stats_label)

func _show_puzzle() -> void:
    current_index = level_manager.get_current_level()
    var puzzle := engine.get_puzzle(current_index)
    if puzzle.is_empty():
        question_label.text = "Barcha darajalar tugadi!"
        answer_input.disabled = true
        action_button.disabled = true
        hint_button.disabled = true
        return

    var completed := level_manager.get_progress_count()
    progress_label.text = "Daraja %d / %d   •   %d%%" % [current_index + 1, engine.puzzles.size(), int(level_manager.get_progress_percent())]
    question_label.text = puzzle.get("prompt", "")
    answer_input.text = ""
    answer_input.editable = true
    answer_input.disabled = false
    action_button.text = "TEKSHIRISH"
    action_button.disabled = false
    hint_button.disabled = false
    feedback_label.text = ""
    hint_label.text = ""
    stats_label.text = "Yechilgan: %d  •  Aniqlik: %.0f%%" % [stats.solved, stats.get_accuracy()]
    hint_used_this_level = false
    puzzle_started_at = Time.get_ticks_msec()
    answer_input.grab_focus()

func _on_answer_submitted(_value: String) -> void:
    _check_answer()

func _on_action_pressed() -> void:
    if action_button.text == "KEYINGI":
        _next_puzzle()
    else:
        _check_answer()

func _check_answer() -> void:
    var puzzle := engine.get_puzzle(current_index)
    if puzzle.is_empty():
        return
    var seconds := float(Time.get_ticks_msec() - puzzle_started_at) / 1000.0
    var category := str(puzzle.get("category", "unknown"))
    if engine.check_answer(current_index, answer_input.text):
        feedback_label.text = "✓ To‘g‘ri!"
        stats.record_solved(seconds, category)
        level_manager.mark_completed(current_index)
        answer_input.editable = false
        action_button.text = "KEYINGI"
        hint_button.disabled = true
        _save()
    else:
        feedback_label.text = "Hali emas. Yana bir bor o‘ylab ko‘ring."
        stats.record_failed(category)
        _save()

func _next_puzzle() -> void:
    var next := current_index + 1
    if next < engine.puzzles.size() and level_manager.set_current_level(next):
        _save()
        _show_puzzle()
    else:
        _show_puzzle()

func _show_hint() -> void:
    var puzzle := engine.get_puzzle(current_index)
    if puzzle.is_empty():
        return
    if hint_used_this_level:
        hint_label.text = "Bu daraja uchun hint allaqachon ishlatildi."
        return
    hint_used_this_level = true
    stats.record_hint(str(puzzle.get("category", "unknown")))
    hint_label.text = "Hint: " + str(puzzle.get("hint", ""))
    _save()

func _save() -> void:
    var level_data := level_manager.to_save_dict()
    SaveManager.save_progress(level_data.current_level, level_data.completed_levels, stats.hints, stats.to_dict())
