extends Node2D

var engine := PuzzleEngine.new()
var repository := PuzzleRepository.new()
var level_manager := LevelManager.new()
var stats := StatsManager.new()
var achievements := AchievementManager.new()
var events := EventTracker.new()
var session := GameSession.new()
var progression := ProgressionService.new()
var daily := DailyChallengeService.new()
var streak := StreakManager.new()
var lives := LifeManager.new()
var current_index := 0
var active_puzzle: PuzzleDefinition
var root_ui: Control
var content: VBoxContainer
var daily_mode := false
var daily_position := 0
var daily_puzzles: Array = []
var timer_label: Label
var timer_tick: Timer
var pause_button: Button
var puzzle_finished := false

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
    daily.setup(repository, save_data)
    streak.load_from_dict(save_data.get("streak", {}))
    lives.load_from_dict(save_data.get("lives", {}))
    current_index = level_manager.get_current_level()
    events.record(EventTracker.APP_STARTED, {"puzzle_count": engine.puzzles.size()})
    timer_tick = Timer.new()
    timer_tick.wait_time = 0.25
    timer_tick.timeout.connect(_on_timer_tick)
    add_child(timer_tick)
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
    timer_tick.stop()
    for child in content.get_children():
        child.queue_free()
    timer_label = null
    pause_button = null
    puzzle_finished = false

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
    button.focus_mode = Control.FOCUS_ALL
    button.pressed.connect(callback)
    return button

func _show_home() -> void:
    daily_mode = false
    _clear_content()
    lives.recover()
    content.add_child(_label("MindShift", 44))
    content.add_child(_label("Javobni topma.\nFikrlash usulingni o‘zgart.", 20))
    content.add_child(_label("Progress: %d / %d   •   ❤️ %d/%d" % [level_manager.get_progress_count(), engine.puzzles.size(), lives.lives, LifeManager.MAX_LIVES], 18))
    content.add_child(_label("🔥 Daily streak: %d   •   Rekord: %d" % [streak.current_streak, streak.best_streak], 17))
    content.add_child(_label("🧠 %s" % str(stats.get_profile().name), 17))
    content.add_child(_button("DAVOM ETISH", _continue_game, 70))
    content.add_child(_button("BUGUNGI CHALLENGE", _start_daily))
    content.add_child(_button("DARAJALAR", _show_levels))
    content.add_child(_button("STATISTIKA", _show_stats))
    content.add_child(_button("SOZLAMALAR", _show_settings))

func _continue_game() -> void:
    if lives.is_empty():
        _show_lives_empty()
        return
    current_index = level_manager.get_current_level()
    _show_puzzle()

func _show_lives_empty() -> void:
    daily_mode = false
    _clear_content()
    var seconds := lives.seconds_to_next_life()
    content.add_child(_label("❤️ Jonlar tugadi", 32))
    content.add_child(_label("Keyingi jon: %d daqiqa %d soniyadan keyin" % [seconds / 60, seconds % 60], 20))
    content.add_child(_button("ORTGA", _show_home))

func _show_levels() -> void:
    daily_mode = false
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
    if lives.is_empty():
        _show_lives_empty()
        return
    _clear_content()
    current_index = level_manager.get_current_level()
    var raw_puzzle := engine.get_puzzle(current_index)
    if raw_puzzle.is_empty():
        content.add_child(_label("Barcha darajalar tugadi!", 28))
        content.add_child(_button("BOSHLASH MENYUSI", _show_home))
        return
    _render_puzzle(PuzzleDefinition.from_dict(raw_puzzle), "Daraja %d / %d" % [current_index + 1, engine.puzzles.size()])

func _render_puzzle(puzzle: PuzzleDefinition, progress_text: String) -> void:
    active_puzzle = puzzle
    session.start(active_puzzle, DifficultyManager.recommended_time(active_puzzle))
    events.record(EventTracker.LEVEL_STARTED, {"level": current_index + 1, "puzzle_id": active_puzzle.id, "difficulty": active_puzzle.difficulty, "daily": daily_mode})
    content.add_child(_label("MINDSHIFT", 32))
    content.add_child(_label(progress_text + "   •   ❤️ %d" % lives.lives, 17))
    content.add_child(_label("%s  •  %s" % [active_puzzle.category.to_upper(), DifficultyManager.tier_name(active_puzzle.difficulty)], 15))
    timer_label = _label("⏱ %ds" % int(session.time_limit_seconds), 17)
    content.add_child(timer_label)
    var question := _label(active_puzzle.prompt, 25)
    question.custom_minimum_size = Vector2(0, 180)
    content.add_child(question)
    var feedback := _label("", 19)
    content.add_child(feedback)
    var hint := _label("", 17)
    content.add_child(hint)
    if AnswerInputFactory.is_button_input(active_puzzle):
        _build_button_answers(feedback, hint)
    else:
        _build_text_answer(feedback, hint)
    content.add_child(_button("HINT", func(): _use_hint(hint), 54))
    pause_button = _button("⏸ PAUZA", _toggle_pause, 54)
    content.add_child(pause_button)
    content.add_child(_button("DARAJALAR" if not daily_mode else "CHALLENGE", _show_levels if not daily_mode else _show_daily, 54))
    timer_tick.start()

func _build_text_answer(feedback: Label, hint: Label) -> void:
    var answer := LineEdit.new()
    answer.name = "AnswerInput"
    answer.placeholder_text = "Raqam kiriting..." if AnswerInputFactory.is_numeric(active_puzzle) else "Javobingiz..."
    answer.custom_minimum_size = Vector2(0, 64)
    answer.add_theme_font_size_override("font_size", 21)
    if AnswerInputFactory.is_numeric(active_puzzle):
        answer.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
    content.add_child(answer)
    content.add_child(_button("TEKSHIRISH", func(): _submit_answer(answer.text, answer, feedback, hint), 68))
    answer.text_submitted.connect(func(_v): _submit_answer(answer.text, answer, feedback, hint))
    answer.grab_focus()

func _build_button_answers(feedback: Label, hint: Label) -> void:
    for value in AnswerInputFactory.button_labels(active_puzzle):
        var value_text := str(value)
        content.add_child(_button(value_text, func(): _submit_answer(value_text, null, feedback, hint), 64))

func _toggle_pause() -> void:
    if puzzle_finished or active_puzzle == null or session.state != GameSession.STATE_ACTIVE or pause_button == null:
        return
    if session.paused:
        session.resume()
        timer_tick.start()
        pause_button.text = "⏸ PAUZA"
    else:
        session.pause()
        timer_tick.stop()
        pause_button.text = "▶ DAVOM ETISH"

func _submit_answer(value: String, input: LineEdit, feedback: Label, hint: Label) -> void:
    if puzzle_finished or active_puzzle == null or session.state != GameSession.STATE_ACTIVE or session.paused:
        return
    var correct := session.submit(value)
    events.record(EventTracker.ANSWER_SUBMITTED, {"puzzle_id": active_puzzle.id, "correct": correct, "attempt": session.attempts, "daily": daily_mode})
    if correct:
        puzzle_finished = true
        timer_tick.stop()
        var elapsed_seconds := int(round(session.get_elapsed_seconds()))
        var result := progression.record_attempt(active_puzzle, true, session.get_elapsed_seconds(), session.attempts, session.hints_used > 0, not daily_mode)
        var reward_multiplier := streak.get_multiplier() if daily_mode else 1.0
        result.score = int(round(float(result.score) * reward_multiplier))
        var multiplier_text := " • 🔥 x%.1f" % reward_multiplier if daily_mode and reward_multiplier > 1.0 else ""
        feedback.text = "✓ TO‘G‘RI!\n%d ⭐  •  +%d BALL%s\n⏱ %ds" % [result.stars, result.score, multiplier_text, elapsed_seconds]
        if input != null:
            input.editable = false
        hint.text = "🧠 " + active_puzzle.explanation if active_puzzle.has_explanation() else ""
        if not result.newly_unlocked.is_empty():
            feedback.text += "\n🏆 Yangi daraja ochildi!"
        if daily_mode:
            daily.record_solved()
        _save()
        if daily_mode:
            daily_position = daily.current_position
            content.add_child(_button("KEYINGISI", _show_daily_puzzle, 68))
        else:
            content.add_child(_button("KEYINGI DARAJA", _next_level, 68))
    else:
        progression.record_attempt(active_puzzle, false, session.get_elapsed_seconds(), session.attempts, session.hints_used > 0, not daily_mode)
        lives.lose_life()
        feedback.text = "Hali emas. ❤️ -1. Yana bir bor o‘ylab ko‘ring."
        _save()
        if lives.is_empty():
            puzzle_finished = true
            timer_tick.stop()
            content.add_child(_button("JONLAR TUGADI", _show_lives_empty, 68))

func _next_level() -> void:
    var next := current_index + 1
    if next < engine.puzzles.size() and level_manager.set_current_level(next):
        _save()
        _show_puzzle()
    else:
        _show_levels()

func _use_hint(hint: Label) -> void:
    if active_puzzle == null or session.paused:
        return
    if session.use_hint():
        progression.record_hint(active_puzzle)
        hint.text = "💡 " + active_puzzle.hint
        _save()
    else:
        hint.text = "Bu daraja uchun hint ishlatilgan."

func _start_daily() -> void:
    if lives.is_empty():
        _show_lives_empty()
        return
    if daily.is_completed():
        _show_daily()
        return
    daily_mode = true
    daily_puzzles = daily.get_puzzles()
    daily_position = daily.current_position
    if daily_position >= daily_puzzles.size():
        _complete_daily()
        return
    _show_daily_puzzle()

func _show_daily_puzzle() -> void:
    if daily_position >= daily_puzzles.size():
        _complete_daily()
        return
    _clear_content()
    var p: PuzzleDefinition = daily_puzzles[daily_position] if daily_puzzles[daily_position] is PuzzleDefinition else PuzzleDefinition.from_dict(daily_puzzles[daily_position])
    _render_puzzle(p, "Daily %d / %d" % [daily_position + 1, daily_puzzles.size()])

func _complete_daily() -> void:
    if daily.is_session_completed():
        daily.mark_completed()
        streak.record_daily_completion(daily.current_date)
    daily_mode = false
    _save()
    _clear_content()
    content.add_child(_label("🔥 DAILY CHALLENGE TUGADI!", 30))
    content.add_child(_label("Bugungi %d ta puzzle yakunlandi." % daily_puzzles.size(), 20))
    content.add_child(_label("🔥 Streak: %d kun • Rekord: %d kun" % [streak.current_streak, streak.best_streak], 18))
    content.add_child(_button("BOSH MENYU", _show_home, 68))

func _show_daily() -> void:
    daily_mode = false
    _clear_content()
    var puzzles := daily.get_puzzles()
    content.add_child(_label("BUGUNGI CHALLENGE", 32))
    content.add_child(_label("%s • %d ta puzzle" % [daily.current_date, puzzles.size()], 18))
    content.add_child(_label("🔥 Streak: %d • Rekord: %d" % [streak.current_streak, streak.best_streak], 17))
    if daily.is_completed():
        content.add_child(_label("✓ Bugungi challenge bajarilgan", 20))
    else:
        for i in range(puzzles.size()):
            var p: PuzzleDefinition = puzzles[i] if puzzles[i] is PuzzleDefinition else PuzzleDefinition.from_dict(puzzles[i])
            var marker := "✓" if i < daily.current_position else ""
            content.add_child(_label("%d. %s %s" % [i + 1, p.prompt, marker], 17))
        content.add_child(_button("DAVOM ETISH", _start_daily, 68))
    content.add_child(_button("ORTGA", _show_home))

func _on_timer_tick() -> void:
    if puzzle_finished or active_puzzle == null or session.state != GameSession.STATE_ACTIVE or session.paused or timer_label == null:
        return
    if session.check_timeout():
        _handle_timeout()
        return
    var remaining := maxi(0, int(ceil(session.get_remaining_seconds())))
    timer_label.text = "⏱ %ds" % remaining

func _handle_timeout() -> void:
    if puzzle_finished:
        return
    puzzle_finished = true
    timer_tick.stop()
    var elapsed := session.get_elapsed_seconds()
    progression.record_attempt(active_puzzle, false, elapsed, session.attempts, session.hints_used > 0, not daily_mode)
    lives.lose_life()
    if daily_mode:
        daily.record_failed()
    events.record(EventTracker.ANSWER_SUBMITTED, {"puzzle_id": active_puzzle.id, "correct": false, "timeout": true, "daily": daily_mode})
    _save()
    _show_timeout()

func _show_timeout() -> void:
    _clear_content()
    content.add_child(_label("⏱ VAQT TUGADI", 34))
    content.add_child(_label("Bu safar ulgurmadingiz. ❤️ -1", 20))
    content.add_child(_label("Javobni tushunib olish ham g‘alabaning bir qismi.", 17))
    if lives.is_empty():
        content.add_child(_button("JONLAR TUGADI", _show_lives_empty, 68))
    elif daily_mode:
        daily_position = daily.current_position
        content.add_child(_button("DAILY DAVOM ETISH", _show_daily_puzzle, 68))
    else:
        content.add_child(_button("KEYINGI DARAJA", _next_level, 68))

func _show_stats() -> void:
    _clear_content()
    var profile := stats.get_profile()
    content.add_child(_label("STATISTIKA", 34))
    content.add_child(_label("Yechilgan: %d\nXatolar: %d\nAniqlik: %.1f%%\nO‘rtacha vaqt: %.1fs" % [stats.solved, stats.failed, stats.get_accuracy(), stats.get_average_time()], 19))
    content.add_child(_label("🔥 Daily streak: %d\n🏆 Rekord: %d" % [streak.current_streak, streak.best_streak], 19))
    content.add_child(_label("🧠 Profil: %s (%.0f/100)" % [profile.name, profile.score], 20))
    content.add_child(_button("ORTGA", _show_home))

func _show_settings() -> void:
    _clear_content()
    content.add_child(_label("SOZLAMALAR", 34))
    content.add_child(_label("MindShift offline ishlaydi.\nProgress qurilmada saqlanadi.", 18))
    content.add_child(_button("PROGRESSNI TOZALASH", _reset_progress, 60))
    content.add_child(_button("ORTGA", _show_home))

func _reset_progress() -> void:
    SaveManager.clear_progress()
    get_tree().reload_current_scene()

func _on_achievement_unlocked(achievement_id: String) -> void:
    events.record("achievement_unlocked", {"id": achievement_id})

func _save() -> void:
    SaveManager.save_progress(level_manager.current_level, level_manager.completed_levels, stats.hints, stats.to_dict(), achievements.to_dict(), {}, daily.to_dict(), lives.to_dict(), streak.to_dict())
