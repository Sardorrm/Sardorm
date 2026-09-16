class_name LocaleRuntimeFixed
extends Node

const LANGUAGES = ["uz", "ru", "en"]
const PUZZLE_TRANSLATIONS = preload("res://src/puzzle_translations.gd")

const TEXTS = {
    "uz": {"DAVOM ETISH":"DAVOM ETISH", "BUGUNGI CHALLENGE":"BUGUNGI CHALLENGE", "DARAJALAR":"DARAJALAR", "STATISTIKA":"STATISTIKA", "YUTUQLAR":"YUTUQLAR", "SOZLAMALAR":"SOZLAMALAR", "ORTGA":"ORTGA", "BOSHLASH MENYUSI":"BOSHLASH MENYUSI", "BOSH MENYU":"BOSH MENYU", "KEYINGISI":"KEYINGISI", "KEYINGI DARAJA":"KEYINGI DARAJA", "QAYTA URINISH":"QAYTA URINISH", "TEKSHIRISH":"TEKSHIRISH", "HINT":"ISHORA", "PAUZA":"PAUZA", "CHALLENGE":"CHALLENGE", "JONLAR TUGADI":"JONLAR TUGADI", "Til":"Til", "PROGRESSNI TOZALASH":"PROGRESSNI TOZALASH", "Barcha darajalar tugadi!":"Barcha darajalar tugadi!", "BOSHLASH / DAVOM ETISH":"BOSHLASH / DAVOM ETISH", "Javobingiz...":"Javobingiz...", "Raqam kiriting...":"Raqam kiriting...", "Darajalar":"Darajalar", "Yechilgan":"Yechilgan", "Jonlar tugadi":"Jonlar tugadi", "Keyingi jon":"Keyingi jon", "Keyingi jon:":"Keyingi jon:", "Barcha darajalar tugadi":"Barcha darajalar tugadi", "Bugungi":"Bugungi", "puzzle yakunlandi.":"puzzle yakunlandi."},
    "ru": {"DAVOM ETISH":"ПРОДОЛЖИТЬ", "BUGUNGI CHALLENGE":"СЕГОДНЯШНИЙ ЧЕЛЛЕНДЖ", "DARAJALAR":"УРОВНИ", "STATISTIKA":"СТАТИСТИКА", "YUTUQLAR":"ДОСТИЖЕНИЯ", "SOZLAMALAR":"НАСТРОЙКИ", "ORTGA":"НАЗАД", "BOSHLASH MENYUSI":"ГЛАВНОЕ МЕНЮ", "BOSH MENYU":"ГЛАВНОЕ МЕНЮ", "KEYINGISI":"СЛЕДУЮЩИЙ", "KEYINGI DARAJA":"СЛЕДУЮЩИЙ УРОВЕНЬ", "QAYTA URINISH":"ПОВТОРИТЬ", "TEKSHIRISH":"ПРОВЕРИТЬ", "HINT":"ПОДСКАЗКА", "PAUZA":"ПАУЗА", "CHALLENGE":"ЧЕЛЛЕНДЖ", "JONLAR TUGADI":"ЖИЗНИ ЗАКОНЧИЛИСЬ", "Til":"Язык", "PROGRESSNI TOZALASH":"СБРОСИТЬ ПРОГРЕСС", "Barcha darajalar tugadi!":"Все уровни пройдены!", "BOSHLASH / DAVOM ETISH":"НАЧАТЬ / ПРОДОЛЖИТЬ", "Javobingiz...":"Ваш ответ...", "Raqam kiriting...":"Введите число...", "Darajalar":"Уровни", "Yechilgan":"Решено", "Jonlar tugadi":"Жизни закончились", "Keyingi jon":"Следующая жизнь", "Keyingi jon:":"Следующая жизнь:", "Barcha darajalar tugadi":"Все уровни пройдены", "Bugungi":"Сегодня", "puzzle yakunlandi.":"головоломки завершены."},
    "en": {"DAVOM ETISH":"CONTINUE", "BUGUNGI CHALLENGE":"TODAY'S CHALLENGE", "DARAJALAR":"LEVELS", "STATISTIKA":"STATS", "YUTUQLAR":"ACHIEVEMENTS", "SOZLAMALAR":"SETTINGS", "ORTGA":"BACK", "BOSHLASH MENYUSI":"MAIN MENU", "BOSH MENYU":"MAIN MENU", "KEYINGISI":"NEXT", "KEYINGI DARAJA":"NEXT LEVEL", "QAYTA URINISH":"RETRY", "TEKSHIRISH":"CHECK", "HINT":"HINT", "PAUZA":"PAUSE", "CHALLENGE":"CHALLENGE", "JONLAR TUGADI":"OUT OF LIVES", "Til":"Language", "PROGRESSNI TOZALASH":"RESET PROGRESS", "Barcha darajalar tugadi!":"All levels complete!", "BOSHLASH / DAVOM ETISH":"START / CONTINUE", "Javobingiz...":"Your answer...", "Raqam kiriting...":"Enter a number...", "Darajalar":"Levels", "Yechilgan":"Solved", "Jonlar tugadi":"Out of lives", "Keyingi jon":"Next life", "Keyingi jon:":"Next life:", "Barcha darajalar tugadi":"All levels complete", "Bugungi":"Today", "puzzle yakunlandi.":"puzzles completed."}
}

var language = "uz"
var selector = null

func _ready():
    var data = SaveManager.load_progress()
    var settings = data.get("settings", {})
    if settings is Dictionary:
        var stored = str(settings.get("language", "uz")).to_lower()
        if LANGUAGES.has(stored):
            language = stored
    get_tree().node_added.connect(_on_node_added)
    call_deferred("_refresh")

func translate(text: String) -> String:
    var table = TEXTS.get(language, TEXTS["uz"])
    return str(table.get(text, text))

func translate_puzzle_text(puzzle_id: String, fallback: String) -> String:
    if language == "uz":
        return fallback
    return PUZZLE_TRANSLATIONS.get(puzzle_id, language, fallback)

func set_language(next_language: String):
    var normalized = next_language.to_lower().strip_edges()
    if not LANGUAGES.has(normalized):
        return
    language = normalized
    _persist()
    _refresh()

func _on_node_added(node):
    if node is Control:
        call_deferred("_translate_tree", node)
        call_deferred("_refresh_selector")

func _refresh():
    var root = get_tree().current_scene
    if root != null:
        _translate_tree(root)
    _refresh_selector()

func _translate_tree(node):
    if node is Button:
        var button = node as Button
        if not str(button.name).begins_with("Language_"):
            var key = str(button.get_meta("mindshift_locale_key", button.text))
            if TEXTS["uz"].has(key):
                button.set_meta("mindshift_locale_key", key)
                button.text = translate(key)
    elif node is Label:
        var label = node as Label
        var key = str(label.get_meta("mindshift_locale_key", label.text))
        if TEXTS["uz"].has(key):
            label.set_meta("mindshift_locale_key", key)
            label.text = translate(key)
    elif node is LineEdit:
        var edit = node as LineEdit
        var key = str(edit.get_meta("mindshift_locale_key", edit.placeholder_text))
        if TEXTS["uz"].has(key):
            edit.set_meta("mindshift_locale_key", key)
            edit.placeholder_text = translate(key)
    for child in node.get_children():
        _translate_tree(child)

func _refresh_selector():
    var title = _find_settings_title(get_tree().current_scene)
    if title == null:
        return
    var parent = title.get_parent()
    if parent == null:
        return
    if selector != null and is_instance_valid(selector):
        _update_selector()
        return
    selector = HBoxContainer.new()
    selector.name = "LanguageSelector"
    selector.add_theme_constant_override("separation", 6)
    parent.add_child(selector)
    var label = Label.new()
    label.set_meta("mindshift_locale_key", "Til")
    label.text = translate("Til")
    label.custom_minimum_size = Vector2(80, 52)
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    selector.add_child(label)
    for code in LANGUAGES:
        _add_language_button(code)
    _update_selector()

func _add_language_button(code: String):
    var button = Button.new()
    button.name = "Language_" + code
    button.text = code.to_upper()
    button.custom_minimum_size = Vector2(72, 52)
    button.toggle_mode = true
    button.set_meta("language_code", code)
    button.pressed.connect(_on_language_button_pressed.bind(code))
    selector.add_child(button)

func _on_language_button_pressed(code: String):
    set_language(code)

func _update_selector():
    if selector == null or not is_instance_valid(selector):
        return
    for child in selector.get_children():
        if child is Button:
            child.button_pressed = str(child.get_meta("language_code", "")) == language
        elif child is Label:
            child.text = translate("Til")

func _find_settings_title(node):
    if node == null:
        return null
    if node is Button or node is Label:
        var text = str(node.text)
        if text == "SOZLAMALAR" or text == "НАСТРОЙКИ" or text == "SETTINGS":
            return node
    for child in node.get_children():
        var found = _find_settings_title(child)
        if found != null:
            return found
    return null

func _persist():
    var data = SaveManager.load_progress()
    var settings = data.get("settings", {}).duplicate(true)
    settings["language"] = language
    SaveManager.save_progress(int(data.get("current_level", 0)), data.get("completed_levels", []), int(data.get("hints_used", 0)), data.get("stats", {}), data.get("achievements", {}), settings, data.get("daily_challenges", {}), data.get("lives", {}), data.get("streak", {}))
