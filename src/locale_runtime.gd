class_name LocaleRuntime
extends Node

const LANGUAGES := ["uz", "ru", "en"]
const LANGUAGE_NAMES := {
    "uz": "🇺🇿 O‘zbek tili",
    "ru": "🇷🇺 Русский",
    "en": "🇬🇧 English"
}

var language := "uz"
var _selector: HBoxContainer
var _last_root: Control

const TEXTS := {
    "uz": {
        "DAVOM ETISH":"DAVOM ETISH", "BUGUNGI CHALLENGE":"BUGUNGI CHALLENGE", "DARAJALAR":"DARAJALAR", "STATISTIKA":"STATISTIKA", "YUTUQLAR":"YUTUQLAR", "SOZLAMALAR":"SOZLAMALAR", "ORTGA":"ORTGA", "BOSHLASH MENYUSI":"BOSHLASH MENYUSI", "BOSH MENYU":"BOSH MENYU", "KEYINGISI":"KEYINGISI", "KEYINGI DARAJA":"KEYINGI DARAJA", "QAYTA URINISH":"QAYTA URINISH", "TEKSHIRISH":"TEKSHIRISH", "HINT":"ISHORA", "PAUZA":"PAUZA", "CHALLENGE":"CHALLENGE", "JONLAR TUGADI":"JONLAR TUGADI", "Til":"Til", "PROGRESSNI TOZALASH":"PROGRESSNI TOZALASH", "Barcha darajalar tugadi!":"Barcha darajalar tugadi!", "BOSHLASH / DAVOM ETISH":"BOSHLASH / DAVOM ETISH", "Javobingiz...":"Javobingiz...", "Raqam kiriting...":"Raqam kiriting..."
    },
    "ru": {
        "DAVOM ETISH":"ПРОДОЛЖИТЬ", "BUGUNGI CHALLENGE":"СЕГОДНЯШНИЙ ЧЕЛЛЕНДЖ", "DARAJALAR":"УРОВНИ", "STATISTIKA":"СТАТИСТИКА", "YUTUQLAR":"ДОСТИЖЕНИЯ", "SOZLAMALAR":"НАСТРОЙКИ", "ORTGA":"НАЗАД", "BOSHLASH MENYUSI":"ГЛАВНОЕ МЕНЮ", "BOSH MENYU":"ГЛАВНОЕ МЕНЮ", "KEYINGISI":"СЛЕДУЮЩИЙ", "KEYINGI DARAJA":"СЛЕДУЮЩИЙ УРОВЕНЬ", "QAYTA URINISH":"ПОВТОРИТЬ", "TEKSHIRISH":"ПРОВЕРИТЬ", "HINT":"ПОДСКАЗКА", "PAUZA":"ПАУЗА", "CHALLENGE":"ЧЕЛЛЕНДЖ", "JONLAR TUGADI":"ЖИЗНИ ЗАКОНЧИЛИСЬ", "Til":"Язык", "PROGRESSNI TOZALASH":"СБРОСИТЬ ПРОГРЕСС", "Barcha darajalar tugadi!":"Все уровни пройдены!", "BOSHLASH / DAVOM ETISH":"НАЧАТЬ / ПРОДОЛЖИТЬ", "Javobingiz...":"Ваш ответ...", "Raqam kiriting...":"Введите число..."
    },
    "en": {
        "DAVOM ETISH":"CONTINUE", "BUGUNGI CHALLENGE":"TODAY’S CHALLENGE", "DARAJALAR":"LEVELS", "STATISTIKA":"STATS", "YUTUQLAR":"ACHIEVEMENTS", "SOZLAMALAR":"SETTINGS", "ORTGA":"BACK", "BOSHLASH MENYUSI":"MAIN MENU", "BOSH MENYU":"MAIN MENU", "KEYINGISI":"NEXT", "KEYINGI DARAJA":"NEXT LEVEL", "QAYTA URINISH":"RETRY", "TEKSHIRISH":"CHECK", "HINT":"HINT", "PAUZA":"PAUSE", "CHALLENGE":"CHALLENGE", "JONLAR TUGADI":"OUT OF LIVES", "Til":"Language", "PROGRESSNI TOZALASH":"RESET PROGRESS", "Barcha darajalar tugadi!":"All levels complete!", "BOSHLASH / DAVOM ETISH":"START / CONTINUE", "Javobingiz...":"Your answer...", "Raqam kiriting...":"Enter a number..."
    }
}

func _ready() -> void:
    var save_data := SaveManager.load_progress()
    var stored = save_data.get("settings", {}).get("language", "uz")
    language = str(stored) if str(stored) in LANGUAGES else "uz"
    get_tree().node_added.connect(_on_node_added)
    call_deferred("_refresh_tree")

func get_language() -> String:
    return language

func set_language(next_language: String) -> void:
    if next_language not in LANGUAGES:
        return
    language = next_language
    _persist_language()
    _refresh_tree()
    _refresh_selector()

func translate(text: String) -> String:
    if TEXTS.has(language) and TEXTS[language].has(text):
        return str(TEXTS[language][text])
    return text

func _on_node_added(node: Node) -> void:
    if node is Control:
        call_deferred("_translate_control", node)
        call_deferred("_refresh_selector")

func _refresh_tree() -> void:
    var root := get_tree().current_scene
    if root is Control:
        _last_root = root
    elif root != null:
        _last_root = root.get_node_or_null("Control") as Control
    for node in get_tree().get_nodes_in_group("mindshift_localizable"):
        _translate_control(node)
    if _last_root != null:
        _translate_control(_last_root)
    _refresh_selector()

func _translate_control(node: Control) -> void:
    if node is Button:
        var button := node as Button
        var translated := translate(button.text)
        if translated != button.text:
            button.text = translated
        if button.tooltip_text != "":
            button.tooltip_text = translate(button.tooltip_text)
    elif node is Label:
        var label := node as Label
        var translated_label := translate(label.text)
        if translated_label != label.text:
            label.text = translated_label
    elif node is LineEdit:
        var edit := node as LineEdit
        edit.placeholder_text = translate(edit.placeholder_text)

func _refresh_selector() -> void:
    var settings_title := _find_text_control("SOZLAMALAR")
    if settings_title == null:
        settings_title = _find_text_control("НАСТРОЙКИ")
    if settings_title == null:
        settings_title = _find_text_control("SETTINGS")
    if settings_title == null:
        return
    var parent := settings_title.get_parent()
    if parent == null:
        return
    if _selector != null and is_instance_valid(_selector):
        if _selector.get_parent() != parent:
            _selector.reparent(parent)
        return
    _selector = HBoxContainer.new()
    _selector.name = "LanguageSelector"
    _selector.add_theme_constant_override("separation", 8)
    parent.add_child(_selector)
    parent.move_child(_selector, settings_title.get_index() + 1)
    var title := Label.new()
    title.text = translate("Til")
    title.custom_minimum_size = Vector2(0, 48)
    title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _selector.add_child(title)
    for code in LANGUAGES:
        var button := Button.new()
        button.text = code.to_upper()
        button.custom_minimum_size = Vector2(88, 52)
        button.toggle_mode = true
        button.button_pressed = code == language
        button.pressed.connect(func(selected := code): set_language(selected))
        _selector.add_child(button)

func _refresh_selector() -> void:
    if _selector == null or not is_instance_valid(_selector):
        return
    for child in _selector.get_children():
        if child is Button:
            child.button_pressed = child.text.to_lower() == language
        elif child is Label:
            child.text = translate("Til")

func _find_text_control(text: String) -> Control:
    for node in get_tree().get_nodes_in_group("mindshift_localizable"):
        if node is Control and ((node is Button and node.text == text) or (node is Label and node.text == text)):
            return node
    return null

func _persist_language() -> void:
    var data := SaveManager.load_progress()
    var settings := data.get("settings", {}).duplicate(true)
    settings["language"] = language
    SaveManager.save_progress(
        int(data.get("current_level", 0)),
        data.get("completed_levels", []),
        int(data.get("hints_used", 0)),
        data.get("stats", {}),
        data.get("achievements", {}),
        settings,
        data.get("daily_challenges", {}),
        data.get("lives", {}),
        data.get("streak", {})
    )
