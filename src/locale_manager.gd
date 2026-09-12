class_name LocaleManager
extends Node

const EN := "en"
const UZ := "uz"
const RU := "ru"
const LANGUAGES := [UZ, RU, EN]

var language := UZ
var _language_button: Button

const UI := {
    "MindShift": {"uz":"MindShift", "ru":"MindShift"},
    "Javobni topma.\nFikrlash usulingni o‘zgart.": {"ru":"Javobni topma.\nFikrlash usulingni o‘zgart."},
    "DAVOM ETISH": {"ru":"ПРОДОЛЖИТЬ"},
    "BUGUNGI CHALLENGE": {"ru":"СЕГОДНЯШНИЙ ЧЕЛЛЕНДЖ"},
    "DARAJALAR": {"ru":"УРОВНИ"},
    "STATISTIKA": {"ru":"СТАТИСТИКА"},
    "YUTUQLAR": {"ru":"ДОСТИЖЕНИЯ"},
    "SOZLAMALAR": {"ru":"НАСТРОЙКИ"},
    "ORTGA": {"ru":"НАЗАД"},
    "BOSHLASH / DAVOM ETISH": {"ru":"НАЧАТЬ / ПРОДОЛЖИТЬ"},
    "BOSHLASH MENYUSI": {"ru":"ГЛАВНОЕ МЕНЮ"},
    "BOSH MENYU": {"ru":"ГЛАВНОЕ МЕНЮ"},
    "KEYINGISI": {"ru":"СЛЕДУЮЩИЙ"},
    "KEYINGI DARAJA": {"ru":"СЛЕДУЮЩИЙ УРОВЕНЬ"},
    "QAYTA URINISH": {"ru":"ПОВТОРИТЬ"},
    "TEKSHIRISH": {"ru":"ПРОВЕРИТЬ"},
    "HINT": {"uz":"ISHORA", "ru":"ПОДСКАЗКА"},
    "PAUZA": {"ru":"ПАУЗА"},
    "CHALLENGE": {"ru":"ЧЕЛЛЕНДЖ"},
    "JONLAR TUGADI": {"ru":"ЖИЗНИ ЗАКОНЧИЛИСЬ"},
    "❤️ Jonlar tugadi": {"ru":"❤️ Жизни закончились"},
    "Raqam kiriting...": {"ru":"Введите число..."},
    "Javobingiz...": {"ru":"Ваш ответ..."},
    "SOZLAMALAR": {"ru":"НАСТРОЙКИ"},
    "🔊 OVOZ: YOQILGAN": {"ru":"🔊 ЗВУК: ВКЛЮЧЁН"},
    "🔇 OVOZ: O‘CHIRILGAN": {"ru":"🔇 ЗВУК: ВЫКЛЮЧЕН"},
    "📳 VIBRATSIYA: YOQILGAN": {"ru":"📳 ВИБРАЦИЯ: ВКЛЮЧЕНА"},
    "📳 VIBRATSIYA: O‘CHIRILGAN": {"ru":"📳 ВИБРАЦИЯ: ВЫКЛЮЧЕНА"},
    "PROGRESSNI TOZALASH": {"ru":"СБРОСИТЬ ПРОГРЕСС"},
    "MindShift offline ishlaydi.\nProgress qurilmada saqlanadi.": {"ru":"MindShift работает офлайн.\nПрогресс сохраняется на устройстве."},
    "Til": {"ru":"Язык"},
    "🇺🇿 O‘zbek tili": {"ru":"🇺🇿 Узбекский"},
    "🇷🇺 Rus tili": {"ru":"🇷🇺 Русский"},
    "🇬🇧 Ingliz tili": {"ru":"🇬🇧 Английский"}
}

const PUZZLE_PROMPTS := {
    "mvp-001": {"uz":"Keyingi son qaysi? 2, 4, 8, 16, ?", "ru":"Какое число следующее? 2, 4, 8, 16, ?"},
    "mvp-002": {"uz":"Qutida 3 ta qizil va 3 ta ko‘k shar bor. Qaramasdan, bir xil rangdagi ikkita sharni olish kafolatlanishi uchun kamida nechta shar olishingiz kerak?", "ru":"В коробке 3 красных и 3 синих шара. Сколько шаров минимум нужно взять вслепую, чтобы гарантированно получить два одного цвета?"},
    "mvp-003": {"uz":"Keyingi son qaysi? 1, 1, 2, 3, 5, 8, ?", "ru":"Что дальше? 1, 1, 2, 3, 5, 8, ?"},
    "mvp-004": {"uz":"Sizda bitta gugurt bor. Qorong‘i xonada sham, moy chirog‘i va kamin bor. Avval nimani yoqasiz?", "ru":"У вас одна спичка. В тёмной комнате есть свеча, масляная лампа и камин. Что вы зажжёте первым?"},
    "mvp-005": {"uz":"Fermerda 17 ta qo‘y bor. 9 tasidan tashqari hammasi qochib ketdi. Nechtasi qoldi?", "ru":"У фермера 17 овец. Все, кроме 9, убежали. Сколько осталось?"},
    "mvp-006": {"uz":"Qaysi biri mos emas: 2, 3, 5, 7, 9, 11?", "ru":"Какое число лишнее: 2, 3, 5, 7, 9, 11?"},
    "mvp-007": {"uz":"Soat 3:15 ni ko‘rsatmoqda. Strelkalar orasidagi kichik burchak qancha?", "ru":"Часы показывают 3:15. Каков меньший угол между стрелками?"},
    "mvp-008": {"uz":"Ikki eshik xavfsizlik va xavfga olib boradi. Bir qo‘riqchi doim yolg‘on, ikkinchisi doim rost gapiradi. Bittasiga bitta savol berishingiz mumkin. Xavfsiz eshikni qanday aniqlaysiz?", "ru":"Две двери ведут к безопасности и опасности. Один страж всегда лжёт, другой всегда говорит правду. Можно задать одному стражу один вопрос. Как определить безопасную дверь?"},
    "mvp-009": {"uz":"Kubning barcha olti yuzi bo‘yalgan va u 27 ta teng kichik kubga kesilgan. Aynan ikki bo‘yalgan yuzi bor nechta kichik kub mavjud?", "ru":"Все шесть граней куба окрашены, затем его разрезали на 27 равных кубиков. Сколько кубиков имеют ровно две окрашенные грани?"},
    "mvp-010": {"uz":"Topshiriqda: ‘Davom etish uchun yashil tugmani bosing’ deyilgan. Yashil tugma o‘chirilgan. Avval nimani tekshirish kerak?", "ru":"В задаче сказано: «Нажмите зелёную кнопку, чтобы продолжить». Зелёная кнопка отключена. Что проверить сначала?"},
    "mvp-011": {"uz":"Keyingi son qaysi? 5, 10, 15, 20, ?", "ru":"Какое число следующее? 5, 10, 15, 20, ?"},
    "mvp-012": {"uz":"Keyingi son qaysi? 1, 4, 9, 16, ?", "ru":"Какое число следующее? 1, 4, 9, 16, ?"},
    "mvp-013": {"uz":"Sizda 10 ta olma bor va 3 tasini berdingiz. Nechta olma qoldi?", "ru":"У вас 10 яблок, и вы отдали 3. Сколько осталось?"},
    "mvp-014": {"uz":"Samolyot ikki davlat chegarasida qulab tushdi. Tirik qolganlarni qayerga dafn qilasiz?", "ru":"Самолёт разбился точно на границе двух стран. Где похоронить выживших?"},
    "mvp-015": {"uz":"Qaysi so‘z boshqacha: CAT, DOG, COW, CAR, HORSE?", "ru":"Какое слово отличается: CAT, DOG, COW, CAR, HORSE?"},
    "mvp-016": {"uz":"Keyingi son qaysi? 20, 18, 15, 11, ?", "ru":"Что дальше? 20, 18, 15, 11, ?"},
    "mvp-017": {"uz":"Xonada 4 ta burchak bor. Har burchakda bittadan mushuk o‘tiribdi. Har bir mushuk 3 ta mushukni ko‘radi. Xonada nechta mushuk bor?", "ru":"В комнате 4 угла. В каждом углу сидит по одной кошке. Каждая кошка видит 3 кошек. Сколько кошек в комнате?"},
    "mvp-018": {"uz":"Kubning tashqi yuzlari bo‘yalgan va u 8 ta teng kubga kesilgan. Aynan uchta bo‘yalgan yuzi bor nechta kichik kub mavjud?", "ru":"Куб окрашен снаружи и разрезан на 8 равных кубиков. Сколько имеют ровно три окрашенные грани?"},
    "mvp-019": {"uz":"Fermerda tovuqlar va sigirlar bor. Jami 10 ta bosh va 28 ta oyoq bor. Nechta sigir bor?", "ru":"У фермера куры и коровы. Всего 10 голов и 28 ног. Сколько коров?"},
    "mvp-020": {"uz":"Sizga: ‘Keyingi javob 5 emas’ deyishdi. Boshqa ma’lumot bo‘lmasa, avval qaysi sonni sinash xavfsiz?", "ru":"Вам сказали: «Следующий ответ не 5». Какое число безопасно проверить первым, если другой информации нет?"},
    "mvp-021": {"uz":"Keyingi son qaysi? 3, 6, 12, 24, ?", "ru":"Какое число следующее? 3, 6, 12, 24, ?"},
    "mvp-022": {"uz":"Keyingi son qaysi? 2, 3, 5, 8, 12, ?", "ru":"Что дальше? 2, 3, 5, 8, 12, ?"},
    "mvp-023": {"uz":"5 ta mashina 5 daqiqada 5 ta buyum ishlab chiqaradi. Xuddi shu tezlikda 100 ta mashina 100 ta buyumni necha daqiqada ishlab chiqaradi?", "ru":"Пять машин делают пять предметов за пять минут. За сколько минут 100 машин сделают 100 предметов с той же скоростью?"},
    "mvp-024": {"uz":"Bir kishi kuniga bir necha marta soqol oladi, lekin baribir soqoli bor. U kim?", "ru":"Мужчина бреется несколько раз в день, но у него всё равно есть борода. Кто он?"},
    "mvp-025": {"uz":"Poygada ikkinchi o‘rindagi odamni quvib o‘tsangiz, nechanchi o‘ringa chiqasiz?", "ru":"Если вы обгоняете человека, занявшего второе место в гонке, какое место занимаете?"},
    "mvp-026": {"uz":"Katta kub 3×3×3 kichik kubga bo‘lindi. Faqat tashqi qismi bo‘yalgan bo‘lsa, nechta kichik kubning bo‘yalgan yuzi yo‘q?", "ru":"Большой куб разделён на 3×3×3 маленьких кубика. Если окрашена только внешняя поверхность, сколько кубиков не имеют окрашенных граней?"},
    "mvp-027": {"uz":"Sizda ikkita arqon bor. Har biri aynan bir soatda yonadi, lekin notekis yonadi. Aynan 30 daqiqani qanday o‘lchaysiz?", "ru":"Есть две верёвки. Каждая горит ровно час, но неравномерно. Как отмерить ровно 30 минут?"},
    "mvp-028": {"uz":"Qulflangan qutida ‘Kalit shu qutining ichida’ degan yozuv bor. Avval qaysi taxminni shubha ostiga olish kerak?", "ru":"На запертом ящике написано: «Ключ внутри этого ящика». Какое предположение нужно поставить под сомнение первым?"},
    "mvp-029": {"uz":"Keyingi son qaysi? 1, 2, 6, 24, 120, ?", "ru":"Какое число следующее? 1, 2, 6, 24, 120, ?"},
    "mvp-030": {"uz":"Qorong‘i xonada sham, plita va chiroq hamda bitta gugurt bor. Avval nimani yoqasiz?", "ru":"В тёмной комнате есть свеча, плита, лампа и одна спичка. Что зажжёте первым?"},
    "choice-031": {"uz":"Qaysi shaklda burchak yo‘q?", "ru":"У какой фигуры нет углов?"},
    "choice-032": {"uz":"Qaysi son juft?", "ru":"Какое число чётное?"},
    "choice-033": {"uz":"To‘g‘ri yoki noto‘g‘ri: Uchburchak har doim uchta tomonga ega.", "ru":"Верно или неверно: у треугольника всегда три стороны."},
    "choice-034": {"uz":"To‘g‘ri yoki noto‘g‘ri: 1 tub son.", "ru":"Верно или неверно: 1 — простое число."},
    "choice-035": {"uz":"10, 20, 30, 40, ? ketma-ketligini ko‘ryapsiz. Qaysi javob eng bevosita qo‘llab-quvvatlanadi?", "ru":"Вы видите последовательность 10, 20, 30, 40, ?. Какой ответ непосредственно подтверждается?"},
    "choice-036": {"uz":"2, 5, 8, 11, ? ketma-ketligini qaysi son to‘ldiradi?", "ru":"Какое число завершает последовательность 2, 5, 8, 11, ?"},
    "choice-037": {"uz":"Vaqtni ko‘rsatish uchun odatda qaysi buyum ishlatiladi?", "ru":"Какой предмет обычно используют, чтобы узнать время?"},
    "choice-038": {"uz":"Agar barcha atirgullar gul bo‘lsa va bu o‘simlik atirgul bo‘lsa, nima albatta to‘g‘ri?", "ru":"Если все розы — цветы, а это растение — роза, что обязательно верно?"},
    "choice-039": {"uz":"Keyingi son qaysi? 30, 27, 24, 21, ?", "ru":"Что дальше? 30, 27, 24, 21, ?"},
    "choice-040": {"uz":"Belgida ‘BEPUL SUV’ deyilgan, ammo kran bo‘sh. Avval qanday xulosa qilish kerak?", "ru":"На табличке написано «БЕСПЛАТНАЯ ВОДА», но кран пуст. Какой вывод сделать первым?"}
}

func _ready() -> void:
    language = str(SaveManager.load_progress().get("settings", {}).get("language", UZ))
    if language not in LANGUAGES:
        language = UZ
    get_tree().node_added.connect(_on_node_added)
    call_deferred("_translate_tree")

func translate(text: String) -> String:
    if language == UZ:
        return text
    if UI.has(text):
        return str(UI[text].get(language, text))
    return text

func translate_puzzle_text(puzzle_id: String, text: String) -> String:
    if language == UZ or not PUZZLE_PROMPTS.has(puzzle_id):
        return text
    return str(PUZZLE_PROMPTS[puzzle_id].get(language, text))

func language_name() -> String:
    if language == UZ: return "🇺🇿 O‘zbek tili"
    if language == RU: return "🇷🇺 Русский"
    return "🇬🇧 English"

func cycle_language() -> void:
    var index := LANGUAGES.find(language)
    language = LANGUAGES[(index + 1) % LANGUAGES.size()]
    _persist_language()
    _translate_tree()

func _persist_language() -> void:
    var data := SaveManager.load_progress()
    var settings: Dictionary = data.get("settings", {}).duplicate(true)
    settings["language"] = language
    SaveManager.save_progress(data.get("current_level", 0), data.get("completed_levels", []), data.get("hints_used", 0), data.get("stats", {}), data.get("achievements", {}), settings, data.get("daily_challenges", {}), data.get("lives", {}), data.get("streak", {}))

func _on_node_added(node: Node) -> void:
    if node is Label or node is Button:
        call_deferred("_translate_node", node)
    if node is Button and str(node.text) == "SOZLAMALAR":
        node.pressed.connect(_on_settings_opened)

func _translate_node(node: Node) -> void:
    if not is_instance_valid(node): return
    if node is Label or node is Button:
        node.text = translate(str(node.text))

func _translate_tree() -> void:
    for node in get_tree().get_nodes_in_group("__nonexistent_localization_group"):
        _translate_node(node)
    _walk(get_tree().root)

func _walk(node: Node) -> void:
    if node is Label or node is Button:
        _translate_node(node)
    for child in node.get_children():
        _walk(child)

func _on_settings_opened() -> void:
    call_deferred("_inject_language_control")

func _inject_language_control() -> void:
    if _language_button != null and is_instance_valid(_language_button):
        _language_button.text = "🌐 " + language_name()
        return
    var settings_label := _find_text_label("SOZLAMALAR")
    if settings_label == null:
        settings_label = _find_text_label("НАСТРОЙКИ")
    if settings_label == null:
        return
    var parent := settings_label.get_parent()
    if parent == null:
        return
    _language_button = Button.new()
    _language_button.custom_minimum_size = Vector2(0, 60)
    _language_button.text = "🌐 " + language_name()
    _language_button.pressed.connect(cycle_language)
    parent.add_child(_language_button)

func _find_text_label(value: String) -> Label:
    return _find_text_label_recursive(get_tree().root, value)

func _find_text_label_recursive(node: Node, value: String) -> Label:
    if node is Label and str(node.text) == value:
        return node
    for child in node.get_children():
        var found := _find_text_label_recursive(child, value)
        if found != null: return found
    return null
