class_name LocaleRuntimeFixed
extends Node

const LANGUAGES := ["uz", "ru", "en"]
const TEXTS := {
    "uz": {"DAVOM ETISH":"DAVOM ETISH", "BUGUNGI CHALLENGE":"BUGUNGI CHALLENGE", "DARAJALAR":"DARAJALAR", "STATISTIKA":"STATISTIKA", "YUTUQLAR":"YUTUQLAR", "SOZLAMALAR":"SOZLAMALAR", "ORTGA":"ORTGA", "BOSHLASH MENYUSI":"BOSHLASH MENYUSI", "BOSH MENYU":"BOSH MENYU", "KEYINGISI":"KEYINGISI", "KEYINGI DARAJA":"KEYINGI DARAJA", "QAYTA URINISH":"QAYTA URINISH", "TEKSHIRISH":"TEKSHIRISH", "HINT":"ISHORA", "PAUZA":"PAUZA", "CHALLENGE":"CHALLENGE", "JONLAR TUGADI":"JONLAR TUGADI", "Til":"Til", "PROGRESSNI TOZALASH":"PROGRESSNI TOZALASH", "Barcha darajalar tugadi!":"Barcha darajalar tugadi!", "BOSHLASH / DAVOM ETISH":"BOSHLASH / DAVOM ETISH", "Javobingiz...":"Javobingiz...", "Raqam kiriting...":"Raqam kiriting..."},
    "ru": {"DAVOM ETISH":"ПРОДОЛЖИТЬ", "BUGUNGI CHALLENGE":"СЕГОДНЯШНИЙ ЧЕЛЛЕНДЖ", "DARAJALAR":"УРОВНИ", "STATISTIKA":"СТАТИСТИКА", "YUTUQLAR":"ДОСТИЖЕНИЯ", "SOZLAMALAR":"НАСТРОЙКИ", "ORTGA":"НАЗАД", "BOSHLASH MENYUSI":"ГЛАВНОЕ МЕНЮ", "BOSH MENYU":"ГЛАВНОЕ МЕНЮ", "KEYINGISI":"СЛЕДУЮЩИЙ", "KEYINGI DARAJA":"СЛЕДУЮЩИЙ УРОВЕНЬ", "QAYTA URINISH":"ПОВТОРИТЬ", "TEKSHIRISH":"ПРОВЕРИТЬ", "HINT":"ПОДСКАЗКА", "PAUZA":"ПАУЗА", "CHALLENGE":"ЧЕЛЛЕНДЖ", "JONLAR TUGADI":"ЖИЗНИ ЗАКОНЧИЛИСЬ", "Til":"Язык", "PROGRESSNI TOZALASH":"СБРОСИТЬ ПРОГРЕСС", "Barcha darajalar tugadi!":"Все уровни пройдены!", "BOSHLASH / DAVOM ETISH":"НАЧАТЬ / ПРОДОЛЖИТЬ", "Javobingiz...":"Ваш ответ...", "Raqam kiriting...":"Введите число..."},
    "en": {"DAVOM ETISH":"CONTINUE", "BUGUNGI CHALLENGE":"TODAY’S CHALLENGE", "DARAJALAR":"LEVELS", "STATISTIKA":"STATS", "YUTUQLAR":"ACHIEVEMENTS", "SOZLAMALAR":"SETTINGS", "ORTGA":"BACK", "BOSHLASH MENYUSI":"MAIN MENU", "BOSH MENYU":"MAIN MENU", "KEYINGISI":"NEXT", "KEYINGI DARAJA":"NEXT LEVEL", "QAYTA URINISH":"RETRY", "TEKSHIRISH":"CHECK", "HINT":"HINT", "PAUZA":"PAUSE", "CHALLENGE":"CHALLENGE", "JONLAR TUGADI":"OUT OF LIVES", "Til":"Language", "PROGRESSNI TOZALASH":"RESET PROGRESS", "Barcha darajalar tugadi!":"All levels complete!", "BOSHLASH / DAVOM ETISH":"START / CONTINUE", "Javobingiz...":"Your answer...", "Raqam kiriting...":"Enter a number..."}
}

const PUZZLES := {
    "mvp-001": {"ru":"Какое число следующее? 2, 4, 8, 16, ?", "en":"What number comes next? 2, 4, 8, 16, ?"},
    "mvp-002": {"ru":"В коробке 3 красных и 3 синих шара. Сколько шаров минимум нужно взять вслепую, чтобы гарантированно получить два одного цвета?", "en":"A box has 3 red and 3 blue balls. What is the minimum number to draw blind to guarantee two of the same color?"},
    "mvp-003": {"ru":"Что дальше? 1, 1, 2, 3, 5, 8, ?", "en":"What comes next? 1, 1, 2, 3, 5, 8, ?"},
    "mvp-004": {"ru":"У вас одна спичка. В тёмной комнате есть свеча, масляная лампа и камин. Что вы зажжёте первым?", "en":"You have one match. In a dark room are a candle, oil lamp and fireplace. What do you light first?"},
    "mvp-005": {"ru":"У фермера 17 овец. Все, кроме 9, убежали. Сколько осталось?", "en":"A farmer has 17 sheep. All but 9 run away. How many remain?"},
    "mvp-006": {"ru":"Какое число лишнее: 2, 3, 5, 7, 9, 11?", "en":"Which one does not fit: 2, 3, 5, 7, 9, 11?"},
    "mvp-007": {"ru":"Часы показывают 3:15. Каков меньший угол между стрелками?", "en":"The clock shows 3:15. What is the smaller angle between the hands?"},
    "mvp-008": {"ru":"Две двери ведут к безопасности и опасности. Один страж всегда лжёт, другой всегда говорит правду. Можно задать одному стражу один вопрос. Как определить безопасную дверь?", "en":"Two doors lead to safety and danger. One guard always lies and the other always tells the truth. You may ask one guard one question. How do you identify the safe door?"},
    "mvp-009": {"ru":"Все шесть граней куба окрашены, затем его разрезали на 27 равных кубиков. Сколько кубиков имеют ровно две окрашенные грани?", "en":"All six faces of a cube are painted, then it is cut into 27 equal cubes. How many have exactly two painted faces?"},
    "mvp-010": {"ru":"В задаче сказано: «Нажмите зелёную кнопку, чтобы продолжить». Зелёная кнопка отключена. Что проверить сначала?", "en":"The task says: ‘Press the green button to continue.’ The green button is disabled. What should you check first?"}
}

var language := "uz"
var selector: HBoxContainer

func _ready() -> void:
    var data := SaveManager.load_progress()
    var stored := str(data.get("settings", {}).get("language", "uz"))
    language = stored if stored in LANGUAGES else "uz"
    get_tree().node_added.connect(_on_node_added)
    call_deferred("_refresh")

func translate(text: String) -> String:
    return str(TEXTS[language].get(text, text))

func translate_puzzle_text(puzzle_id: String, fallback: String) -> String:
    if language == "uz":
        return fallback
    if not PUZZLES.has(puzzle_id):
        return fallback
    return str(PUZZLES[puzzle_id].get(language, fallback))

func set_language(next_language: String) -> void:
    if next_language not in LANGUAGES:
        return
    language = next_language
    _persist()
    _refresh()

func _on_node_added(node: Node) -> void:
    if node is Control:
        call_deferred("_translate_tree", node)
        call_deferred("_refresh_selector")

func _refresh() -> void:
    var root := get_tree().current_scene
    if root != null:
        _translate_tree(root)
    _refresh_selector()

func _translate_tree(node: Node) -> void:
    if node is Button:
        var b := node as Button
        b.text = translate(b.text)
    elif node is Label:
        var l := node as Label
        l.text = translate(l.text)
    elif node is LineEdit:
        var e := node as LineEdit
        e.placeholder_text = translate(e.placeholder_text)
    for child in node.get_children():
        _translate_tree(child)

func _refresh_selector() -> void:
    var title := _find_settings_title(get_tree().current_scene)
    if title == null:
        return
    var parent := title.get_parent()
    if parent == null:
        return
    if selector != null and is_instance_valid(selector):
        _update_selector()
        return
    selector = HBoxContainer.new()
    selector.name = "LanguageSelector"
    selector.add_theme_constant_override("separation", 6)
    parent.add_child(selector)
    var label := Label.new()
    label.text = translate("Til")
    label.custom_minimum_size = Vector2(80, 52)
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    selector.add_child(label)
    for code in LANGUAGES:
        var button := Button.new()
        button.name = "Language_" + code
        button.text = code.to_upper()
        button.custom_minimum_size = Vector2(72, 52)
        button.toggle_mode = true
        button.pressed.connect(func(): set_language(code))
        selector.add_child(button)
    _update_selector()

func _update_selector() -> void:
    if selector == null or not is_instance_valid(selector):
        return
    for child in selector.get_children():
        if child is Button:
            child.button_pressed = str(child.name).replace("Language_", "") == language
        elif child is Label:
            child.text = translate("Til")

func _find_settings_title(node: Node) -> Control:
    if node == null:
        return null
    if node is Button and (node.text == "SOZLAMALAR" or node.text == "НАСТРОЙКИ" or node.text == "SETTINGS"):
        return node
    if node is Label and (node.text == "SOZLAMALAR" or node.text == "НАСТРОЙКИ" or node.text == "SETTINGS"):
        return node
    for child in node.get_children():
        var found := _find_settings_title(child)
        if found != null:
            return found
    return null

func _persist() -> void:
    var data := SaveManager.load_progress()
    var settings := data.get("settings", {}).duplicate(true)
    settings["language"] = language
    SaveManager.save_progress(int(data.get("current_level", 0)), data.get("completed_levels", []), int(data.get("hints_used", 0)), data.get("stats", {}), data.get("achievements", {}), settings, data.get("daily_challenges", {}), data.get("lives", {}), data.get("streak", {}))
