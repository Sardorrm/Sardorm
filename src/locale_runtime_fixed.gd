class_name LocaleRuntimeFixed
extends Node

const LANGUAGES: Array[String] = ["uz", "ru", "en"]
const PUZZLE_TRANSLATIONS = preload("res://src/puzzle_translations.gd")

const TEXTS: Dictionary = {
    "uz": {"DAVOM ETISH":"DAVOM ETISH", "BUGUNGI CHALLENGE":"BUGUNGI CHALLENGE", "DARAJALAR":"DARAJALAR", "STATISTIKA":"STATISTIKA", "YUTUQLAR":"YUTUQLAR", "SOZLAMALAR":"SOZLAMALAR", "ORTGA":"ORTGA", "BOSHLASH MENYUSI":"BOSHLASH MENYUSI", "BOSH MENYU":"BOSH MENYU", "KEYINGISI":"KEYINGISI", "KEYINGI DARAJA":"KEYINGI DARAJA", "QAYTA URINISH":"QAYTA URINISH", "TEKSHIRISH":"TEKSHIRISH", "HINT":"ISHORA", "PAUZA":"PAUZA", "CHALLENGE":"CHALLENGE", "JONLAR TUGADI":"JONLAR TUGADI", "Til":"Til", "PROGRESSNI TOZALASH":"PROGRESSNI TOZALASH", "Javobingiz...":"Javobingiz...", "Raqam kiriting...":"Raqam kiriting...", "Darajalar":"Darajalar", "Yechilgan":"Yechilgan", "Keyingi jon":"Keyingi jon", "Keyingi jon:":"Keyingi jon:", "Bugungi":"Bugungi", "puzzle yakunlandi.":"puzzle yakunlandi."},
    "ru": {"DAVOM ETISH":"ПРОДОЛЖИТЬ", "BUGUNGI CHALLENGE":"СЕГОДНЯШНИЙ ЧЕЛЛЕНДЖ", "DARAJALAR":"УРОВНИ", "STATISTIKA":"СТАТИСТИКА", "YUTUQLAR":"ДОСТИЖЕНИЯ", "SOZLAMALAR":"НАСТРОЙКИ", "ORTGA":"НАЗАД", "BOSHLASH MENYUSI":"ГЛАВНОЕ МЕНЮ", "BOSH MENYU":"ГЛАВНОЕ МЕНЮ", "KEYINGISI":"СЛЕДУЮЩИЙ", "KEYINGI DARAJA":"СЛЕДУЮЩИЙ УРОВЕНЬ", "QAYTA URINISH":"ПОВТОРИТЬ", "TEKSHIRISH":"ПРОВЕРИТЬ", "HINT":"ПОДСКАЗКА", "PAUZA":"ПАУЗА", "CHALLENGE":"ЧЕЛЛЕНДЖ", "JONLAR TUGADI":"ЖИЗНИ ЗАКОНЧИЛИСЬ", "Til":"Язык", "PROGRESSNI TOZALASH":"СБРОСИТЬ ПРОГРЕСС", "Javobingiz...":"Ваш ответ...", "Raqam kiriting...":"Введите число...", "Darajalar":"Уровни", "Yechilgan":"Решено", "Keyingi jon":"Следующая жизнь", "Keyingi jon:":"Следующая жизнь:", "Bugungi":"Сегодня", "puzzle yakunlandi.":"головоломки завершены."},
    "en": {"DAVOM ETISH":"CONTINUE", "BUGUNGI CHALLENGE":"TODAY'S CHALLENGE", "DARAJALAR":"LEVELS", "STATISTIKA":"STATS", "YUTUQLAR":"ACHIEVEMENTS", "SOZLAMALAR":"SETTINGS", "ORTGA":"BACK", "BOSHLASH MENYUSI":"MAIN MENU", "BOSH MENYU":"MAIN MENU", "KEYINGISI":"NEXT", "KEYINGI DARAJA":"NEXT LEVEL", "QAYTA URINISH":"RETRY", "TEKSHIRISH":"CHECK", "HINT":"HINT", "PAUZA":"PAUSE", "CHALLENGE":"CHALLENGE", "JONLAR TUGADI":"OUT OF LIVES", "Til":"Language", "PROGRESSNI TOZALASH":"RESET PROGRESS", "Javobingiz...":"Your answer...", "Raqam kiriting...":"Enter a number...", "Darajalar":"Levels", "Yechilgan":"Solved", "Keyingi jon":"Next life", "Keyingi jon:":"Next life:", "Bugungi":"Today", "puzzle yakunlandi.":"puzzles completed."}
}

var language: String = "uz"
var selector: HBoxContainer

func _ready() -> void:
    var data: Dictionary = SaveManager.load_progress()
    var raw_settings = data.get("settings", {})
    var stored: String = str(raw_settings.get("language", "uz")) if raw_settings is Dictionary else "uz"
    language = stored if stored in LANGUAGES else "uz"
    get_tree().node_added.connect(_on_node_added)
    call_deferred("_refresh")

func translate(text: String) -> String:
    var table: Dictionary = TEXTS.get(language, TEXTS["uz"])
    return str(table.get(text, text))

func translate_puzzle_text(puzzle_id: String, fallback: String) -> String:
    if language == "uz":
        return fallback
    var translated: String = PuzzleTranslations.get(puzzle_id, language, "")
    return fallback if translated.is_empty() else translated

func set_language(next_language: String) -> void:
    var normalized: String = next_language.to_lower().strip_edges()
    if normalized not in LANGUAGES:
        return
    language = normalized
    _persist()
    _refresh()

func _on_node_added(node: Node) -> void:
    if node is Control:
        call_deferred("_translate_tree", node)
        call_deferred("_refresh_selector")

func _refresh() -> void:
    var root: Node = get_tree().current_scene
    if root != null:
        _translate_tree(root)
    _refresh_selector()

func _translate_tree(node: Node) -> void:
    if node is Button:
        var button: Button = node as Button
        if not button.name.begins_with("Language_"):
            var key: String = str(button.get_meta("mindshift_locale_key", button.text))
            if TEXTS["uz"].has(key):
                button.set_meta("mindshift_locale_key", key)
                button.text = translate(key)
    elif node is Label:
        var label: Label = node as Label
        var label_key: String = str(label.get_meta("mindshift_locale_key", label.text))
        if TEXTS["uz"].has(label_key):
            label.set_meta("mindshift_locale_key", label_key)
            label.text = translate(label_key)
    elif node is LineEdit:
        var edit: LineEdit = node as LineEdit
        var key: String = str(edit.get_meta("mindshift_locale_key", edit.placeholder_text))
        if TEXTS["uz"].has(key):
            edit.set_meta("mindshift_locale_key", key)
            edit.placeholder_text = translate(key)
    for child in node.get_children():
        _translate_tree(child)

func _refresh_selector() -> void:
    var root: Node = get_tree().current_scene
    var title: Node = _find_settings_title(root)
    if title == null:
        return
    var parent: Node = title.get_parent()
    if parent == null:
        return
    if selector != null and is_instance_valid(selector):
        _update_selector()
        return
    selector = HBoxContainer.new()
    selector.name = "LanguageSelector"
    parent.add_child(selector)
    var label: Label = Label.new()
    label.set_meta("mindshift_locale_key", "Til")
    label.text = translate("Til")
    label.custom_minimum_size = Vector2(80, 52)
    selector.add_child(label)
    for code in LANGUAGES:
        _add_language_button(code)
    _update_selector()

func _add_language_button(code: String) -> void:
    var button: Button = Button.new()
    button.name = "Language_" + code
    button.text = code.to_upper()
    button.custom_minimum_size = Vector2(72, 52)
    button.toggle_mode = true
    button.set_meta("language_code", code)
    button.pressed.connect(_on_language_button_pressed.bind(code))
    selector.add_child(button)

func _on_language_button_pressed(code: String) -> void:
    set_language(code)

func _update_selector() -> void:
    if selector == null or not is_instance_valid(selector):
        return
    for child in selector.get_children():
        if child is Button:
            var button: Button = child as Button
            button.button_pressed = str(button.get_meta("language_code", "")) == language
        elif child is Label:
            var label: Label = child as Label
            label.text = translate("Til")

func _find_settings_title(node: Node) -> Node:
    if node == null:
        return null
    if node is Button or node is Label:
        var text: String = str(node.text)
        if text == "SOZLAMALAR" or text == "НАСТРОЙКИ" or text == "SETTINGS":
            return node
    for child in node.get_children():
        var found: Node = _find_settings_title(child)
        if found != null:
            return found
    return null

func _persist() -> void:
    var data: Dictionary = SaveManager.load_progress()
    var raw_settings = data.get("settings", {})
    var settings: Dictionary = raw_settings.duplicate(true) if raw_settings is Dictionary else {}
    settings["language"] = language
    SaveManager.save_progress(int(data.get("current_level", 0)), data.get("completed_levels", []), int(data.get("hints_used", 0)), data.get("stats", {}), data.get("achievements", {}), settings, data.get("daily_challenges", {}), data.get("lives", {}), data.get("streak", {}))
