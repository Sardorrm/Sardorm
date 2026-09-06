extends Node2D

var engine := PuzzleEngine.new()
var repository := PuzzleRepository.new()
var level_manager := LevelManager.new()
var stats := StatsManager.new()
var achievements := AchievementManager.new()
var events := EventTracker.new()
var session := GameSession.new()
var progression := ProgressionService.new()
var current_index := 0
var active_puzzle: PuzzleDefinition
var root_ui: Control
var content: VBoxContainer

func _ready() -> void:
    if not engine.load_from_file("res://data/puzzles.json"):
        push_error("Could not load puzzle data: " + engine.last_error)
        return
    if not repository.load_from_file("res://data/puzzles.json"):
        push_error("Could not load puzzle repository: " + repository.last_error)
        return

    var save_data := SaveManager.load_progress()
    stats.load_from_dict(save_data.get("stats", {}))
    achievements.load_from_dict(save_data.get("achievements", {}))
    level_manager.setup(engine, save_data)
    progression.setup(level_manager, stats, achievements, events)
    progression.achievement_unlocked.connect(_on_achievement_unlocked)
    current_index = level_manager.get_current_level()
    events.record(EventTracker.APP_STARTED, {"puzzle_count": engine.puzzles.size()})
    _build_shell()
    _show_home()

func _build_shell() -> void:
    root_ui = Control.new()
    root_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(root_ui)
    var background := ColorRect.new()
    background.color = Color("0b0b12")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root_ui.add_child(background)
    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 24)
    margin.add_theme_constant_override("margin_right", 24)
    margin.add_theme_constant_override("margin_top", 28)
    margin.add_theme_constant_override("margin_bottom", 28)
    root_ui.add_child(margin)
    content = VBoxContainer.new()
    content.add_theme_constant_override("separation", 14)
    margin.add_child(content)

func _clear_content() -> void:
    for child in content.get_children():
        child.queue_free()

func _label(text: String, size: int = 18) -> Label:
    var label := Label.new()
    label.text = text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", size)
    return label

func _button(text: String, callback: Callable, height: int = 62) -> Button:
    var button := Button.new()
    button.text = text
    button.custom_minimum_size = Vector2(0, height)
    button.add_theme_font_size_override("font_size", 20)
    button.pressed.connect(callback)
    return button

func _show_home() -> void:
    _clear_content()
    content.add_child(_label("MindShift", 44))
    content.add_child(_label("Javobni topma.\nFikrlash usulingni o‘zgart.", 20))
    content.add_spacer(false)
    content.add_child(_label("Progress: %d / %d" % [level_manager.get_progress_count(), engine.puzzles.size()], 18))
    content.add_child(_label("🧠 %s" % str(stats.get_profile().name), 17))
    content.add_child(_button("DAVOM ETISH", _continue_game, 70))
    content.add_child(_button("DARAJALAR", _show_levels))
    content.add_child(_button("STATISTIKA", _show_stats))
    content.add_child(_button("SOZLAMALAR", _show_settings))

func _continue_game() -> void:
    current_index = level_manager.get_current_level()
    _show_puzzle()

func _show_levels() -> void:
    _clear_content()
    content.add_child(_label("Darajalar", 34))
    content.add_child(_label("Yechilgan: %d / %d" % [level_manager.get_progress_count(), engine.puzzles.size()]))
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_child(scroll)
    var grid := GridContainer.new()
    grid.columns = 4
    grid.add_theme_constant_override("h_separation", 8)
    grid.add_theme_constant_override("v_separation", 8)
    scroll.add_child(grid)
    for i in range(engine.puzzles.size()):
        var level_button := Button.new()
        level_button.text = str(i + 1) + (" ✓" if level_manager.is_completed(i) else "")
        level_button.custom_minimum_size = Vector2(72, 58)
        level_button.disabled = not level_manager.is_unlocked(i)
        level_button.pressed.connect(func(idx := i): _select_level(idx))
        grid.add_child(level_button)
    content.add_child(_button("ORTGA", _show_home))

func _select_level(index: int) -> void:
    if level_manager.set_current_level(index):
        current_index = index
        events.record(EventTracker.LEVEL_SELECTED, {"level": index + 1})
        _save()
        _show_puzzle()

func _show_puzzle() -> void:
    _clear_content()
    current_index = level_manager.get_current_level()
    var raw_puzzle := engine.get_puzzle(current_index)
    if raw_puzzle.is_empty():
        content.add_child(_label("Barcha darajalar tugadi!", 28))
        content.add_child(_button("BOSHLASH MENYUSI", _show_home))
        return

    active_puzzle = PuzzleDefinition.from_dict(raw_puzzle)
    session.start(active_puzzle)
    events.record(EventTracker.LEVEL_STARTED, {"level": current_index + 1, "puzzle_id": active_puzzle.id, "difficulty": active_puzzle.difficulty})

    content.add_child(_label("MINDSHIFT", 32))
    content.add_child(_label("Daraja %d / %d   •   %d%%" % [current_index + 1, engine.puzzles.size(), int(level_manager.get_progress_percent())], 17))
    content.add_child(_label("%s  •  QIYINLIK %d" % [active_puzzle.category.to_upper(), active_puzzle.difficulty], 15))

    var question := _label(active_puzzle.prompt, 25)
    question.custom_minimum_size = Vector2(0, 220)
    content.add_child(question)

    var answer := LineEdit.new()
    answer.name = "AnswerInput"
    answer.placeholder_text = "Raqam kiriting..." if PuzzleInteraction.input_type(active_puzzle) == PuzzleInteraction.TYPE_NUMBER else "Javobingiz..."
    answer.custom_minimum_size = Vector2(0, 64)
    answer.add_theme_font_size_override("font_size", 21)
    if PuzzleInteraction.input_type(active_puzzle) == PuzzleInteraction.TYPE_NUMBER:
        answer.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
    content.add_child(answer)

    var feedback := _label("", 19)
    content.add_child(feedback)
    var hint := _label("", 17)
    content.add_child(hint)

    content.add_child(_button("TEKSHIRISH", func(): _check_answer(answer, feedback, hint), 68))
    content.add_child(_button("HINT", func(): _use_hint(hint), 54))
    content.add_child(_button("DARAJALAR", _show_levels, 54))
    answer.text_submitted.connect(func(_v): _check_answer(answer, feedback, hint))
    answer.grab_focus()

func _check_answer(answer: LineEdit, feedback: Label, hint: Label) -> void:
    if not answer.editable or active_puzzle == null or session.state != GameSession.STATE_ACTIVE:
        return
    var correct := session.submit(answer.text)
    events.record(EventTracker.ANSWER_SUBMITTED, {"puzzle_id": active_puzzle.id, "correct": correct, "attempt": session.attempts})
    if correct:
        var result := progression.record_attempt(active_puzzle, true, session.get_elapsed_seconds(), session.attempts, session.hints_used > 0)
        feedback.text = "✓ TO‘G‘RI!  %d ⭐  +%d" % [result.stars, result.score]
        answer.editable = false
        _save()
        if active_puzzle.has_explanation():
            hint.text = "🧠 " + active_puzzle.explanation
        elif not result.newly_unlocked.is_empty():
            hint.text = "🏆 Yangi achievement!"
        if not result.newly_unlocked.is_empty():
            feedback.text += "  🏆"
        content.add_child(_button("KEYINGI DARAJA", _next_level, 68))
    else:
        progression.record_attempt(active_puzzle, false, session.get_elapsed_seconds(), session.attempts, session.hints_used > 0)
        feedback.text = "Hali emas. Yana bir bor o‘ylab ko‘ring."
        _save()

func _next_level() -> void:
    var next := current_index + 1
    if next < engine.puzzles.size() and level_manager.set_current_level(next):
        _save()
        _show_puzzle()
    else:
        _show_levels()

func _use_hint(hint: Label) -> void:
    if active_puzzle == null:
        return
    if session.use_hint():
        progression.record_hint(active_puzzle)
        hint.text = "💡 " + active_puzzle.hint
        _save()
    else:
        hint.text = "Bu daraja uchun hint ishlatilgan."

func _show_stats() -> void:
    _clear_content()
    var profile := stats.get_profile()
    content.add_child(_label("STATISTIKA", 34))
    content.add_child(_label("🧠 " + str(profile.name), 27))
    content.add_child(_label("Profil balli: %.0f" % float(profile.score), 18))
    content.add_child(_label("Yechilgan: %d\nXato: %d\nAniqlik: %.0f%%\nHintlar: %d\nO‘rtacha vaqt: %.1f s" % [stats.solved, stats.failed, stats.get_accuracy(), stats.hints, stats.get_average_time()], 19))
    content.add_child(_label("Achievementlar: %d / %d" % [achievements.unlocked.size(), AchievementManager.DEFINITIONS.size()], 17))
    content.add_child(_button("DARAJALAR", _show_levels))
    content.add_child(_button("ORTGA", _show_home))

func _show_settings() -> void:
    _clear_content()
    content.add_child(_label("SOZLAMALAR", 34))
    content.add_child(_label("MindShift ma’lumotlari telefonda saqlanadi.", 17))
    content.add_child(_button("PROGRESSNI TOZALASH", _reset_progress))
    content.add_child(_button("ORTGA", _show_home))

func _reset_progress() -> void:
    SaveManager.clear_progress()
    stats = StatsManager.new()
    achievements = AchievementManager.new()
    progression.setup(level_manager, stats, achievements, events)
    level_manager.setup(engine, {})
    current_index = 0
    _save()
    _show_home()

func _on_achievement_unlocked(_achievement_id: String) -> void:
    _save()

func _save() -> void:
    var level_data := level_manager.to_save_dict()
    SaveManager.save_progress(level_data.current_level, level_data.completed_levels, stats.hints, stats.to_dict(), achievements.to_dict())
