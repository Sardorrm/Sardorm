class_name LocaleRuntimeFixed
extends Node

const LANGUAGES := ["uz", "ru", "en"]
const PUZZLE_TRANSLATIONS := preload("res://src/puzzle_translations.gd")

const TEXTS := {
    "uz": {"DAVOM ETISH":"DAVOM ETISH", "BUGUNGI CHALLENGE":"BUGUNGI CHALLENGE", "DARAJALAR":"DARAJALAR", "STATISTIKA":"STATISTIKA", "YUTUQLAR":"YUTUQLAR", "SOZLAMALAR":"SOZLAMALAR", "ORTGA":"ORTGA", "BOSHLASH MENYUSI":"BOSHLASH MENYUSI", "BOSH MENYU":"BOSH MENYU", "KEYINGISI":"KEYINGISI", "KEYINGI DARAJA":"KEYINGI DARAJA", "QAYTA URINISH":"QAYTA URINISH", "TEKSHIRISH":"TEKSHIRISH", "HINT":"ISHORA", "PAUZA":"PAUZA", "CHALLENGE":"CHALLENGE", "JONLAR TUGADI":"JONLAR TUGADI", "Til":"Til", "PROGRESSNI TOZALASH":"PROGRESSNI TOZALASH", "Javobingiz...":"Javobingiz...", "Raqam kiriting...":"Raqam kiriting...", "Darajalar":"Darajalar", "Yechilgan":"Yechilgan", "Keyingi jon":"Keyingi jon", "Keyingi jon:":"Keyingi jon:", "Bugungi":"Bugungi", "puzzle yakunlandi.":"puzzle yakunlandi."},
    "ru": {"DAVOM ETISH":"ПРОДОЛЖИТЬ", "BUGUNGI CHALLENGE":"СЕГОДНЯШНИЙ ЧЕЛЛЕНДЖ", "DARAJALAR":"УРОВНИ", "STATISTIKA":"СТАТИСТИКА", "YUTUQLAR":"ДОСТИЖЕНИЯ", "SOZLAMALAR":"НАСТРОЙКИ", "ORTGA":"НАЗАД", "BOSHLASH MENYUSI":"ГЛАВНОЕ МЕНЮ", "BOSH MENYU":"ГЛАВНОЕ МЕНЮ", "KEYINGISI":"СЛЕДУЮЩИЙ", "KEYINGI DARAJA":"СЛЕДУЮЩИЙ УРОВЕНЬ", "QAYTA URINISH":"ПОВТОРИТЬ", "TEKSHIRISH":"ПРОВЕРИТЬ", "HINT":"ПОДСКАЗКА", "PAUZA":"ПАУЗА", "CHALLENGE":"ЧЕЛЛЕНДЖ", "JONLAR TUGADI":"ЖИЗНИ ЗАКОНЧИЛИСЬ", "Til":"Язык", "PROGRESSNI TOZALASH":"СБРОСИТЬ ПРОГРЕСС", "Javobingiz...":"Ваш ответ...", "Raqam kiriting...":"Введите число...", "Darajalar":"Уровни", "Yechilgan":"Решено", "Keyingi jon":"Следующая жизнь", "Keyingi jon:":"Следующая жизнь:", "Bugungi":"Сегодня", "puzzle yakunlandi.":"головоломки завершены."},
    "en": {"DAVOM ETISH":"CONTINUE", "BUGUNGI CHALLENGE":"TODAY'S CHALLENGE", "DARAJALAR":"LEVELS", "STATISTIKA":"STATS", "YUTUQLAR":"ACHIEVEMENTS", "SOZLAMALAR":"SETTINGS", "ORTGA":"BACK", "BOSHLASH MENYUSI":"MAIN MENU", "BOSH MENYU":"MAIN MENU", "KEYINGISI":"NEXT", "KEYINGI DARAJA":"NEXT LEVEL", "QAYTA URINISH":"RETRY", "TEKSHIRISH":"CHECK", "HINT":"HINT", "PAUZA":"PAUSE", "CHALLENGE":"CHALLENGE", "JONLAR TUGADI":"OUT OF LIVES", "Til":"Language", "PROGRESSNI TOZALASH":"RESET PROGRESS", "Javobingiz...":"Your answer...", "Raqam kiriting...":"Enter a number...", "Darajalar":"Levels", "Yechilgan":"Solved", "Keyingi jon":"Next life", "Keyingi jon:":"Next life:", "Bugungi":"Today", "puzzle yakunlandi.":"puzzles completed."}
}

var language := "uz"
var selector: HBoxContainer

func _ready() -> void:
    var data: Dictionary = SaveManager.load_progress()
    var stored := str(data.get("settings", {}).get("language", "uz"))
    language = stored if stored in LANGUAGES else "uz"
    get_tree().node_added.connect(_on_node_added)
    call_deferred("_refresh")

func translate(text: String) -> String:
    var table: Dictionary = TEXTS.get(language, TEXTS["uz"])
    return str(table.get(text, text))

func translate_puzzle_text(puzzle_id: String, fallback: String) -> String:
    if language == "uz":
        return fallback
    var translated := PuzzleTranslations.get(puzzle_id, language, "")
    return fallback if translated.is_empty() else translated

func set_language(next_language: String) -> void:
    var normalized := next_language.to_lower().strip_edges()
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
        var b: Button = node as Button
        if not b.name.begins_with("Language_"):
            var key := str(b.get_meta("mindshift_locale_key", b.text))
            if TEXTS["uz"].has(key):
                b.set_meta("mindshift_locale_key", key)
                b.text = translate(key)
    elif node is Label:
        var l: Label = node as Label
        var label_key := str(l.get_meta("mindshift_locale_key", l.text))
        if TEXTS["uz"].has(label_key):
            l.set_meta("mindshift_locale_key", label_key)
            l.text = translate(label_key)
    elif node is LineEdit:
        var e: LineEdit = node as LineEdit
        var key := str(e.get_meta("mindshift_locale_key", e.placeholder_text))
        if TEXTS["uz"].has(key):
            e.set_meta("mindshift_locale_key", key)
            e.placeholder_text = translate(key)
    for child in node.get_children():
        _translate_tree(child)

func _refresh_selector() -> void:
    var root: Node = get_tree().current_scene
    var title = _find_settings_title(root)
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
    var label := Label.new()
    label.set_meta("mindshift_locale_key", "Til")
    label.text = translate("Til")
    label.custom_minimum_size = Vector2(80, 52)
    selector.add_child(label)
    for code in LANGUAGES:
        _add_language_button(code)
    _update_selector()

func _add_language_button(code: String) -> void:
    var button := Button.new()
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
            var b: Button = child as Button
            b.button_pressed = str(b.get_meta("language_code", "")) == language
        elif child is Label:
            var l: Label = child as Label
            l.text = translate("Til")

func _find_settings_title(node: Node):
    if node == null:
        return null
    if node is Button or node is Label:
        var text := str(node.text)
        if text == "SOZLAMALAR" or text == "НАСТРОЙКИ" or text == "SETTINGS":
            return node
    for child in node.get_children():
        var found = _find_settings_title(child)
        if found != null:
            return found
    return null

func _persist() -> void:
    var data: Dictionary = SaveManager.load_progress()
    var raw_settings = data.get("settings", {})
    var settings: Dictionary = raw_settings.duplicate(true) if raw_settings is Dictionary else {}
    settings["language"] = language
    SaveManager.save_progress(int(data.get("current_level", 0)), data.get("completed_levels", []), int(data.get("hints_used", 0)), data.get("stats", {}), data.get("achievements", {}), settings, data.get("daily_challenges", {}), data.get("lives", {}), data.get("streak", {}))
