class_name PuzzleTranslations
extends RefCounted

const TEXTS = {
    "mvp-001": {"ru": "Какое число следующее? 2, 4, 8, 16, ?", "en": "What number comes next? 2, 4, 8, 16, ?"},
    "mvp-002": {"ru": "В коробке 3 красных и 3 синих шара. Сколько шаров минимум нужно взять вслепую, чтобы гарантированно получить два одного цвета?", "en": "A box has 3 red and 3 blue balls. What is the minimum number to draw blind to guarantee two of the same color?"},
    "mvp-003": {"ru": "Что дальше? 1, 1, 2, 3, 5, 8, ?", "en": "What comes next? 1, 1, 2, 3, 5, 8, ?"},
    "mvp-004": {"ru": "У вас одна спичка. В темной комнате есть свеча, масляная лампа и камин. Что вы зажжете первым?", "en": "You have one match. In a dark room are a candle, oil lamp and fireplace. What do you light first?"},
    "mvp-005": {"ru": "У фермера 17 овец. Все, кроме 9, убежали. Сколько осталось?", "en": "A farmer has 17 sheep. All but 9 run away. How many remain?"},
    "mvp-006": {"ru": "Какое число лишнее: 2, 3, 5, 7, 9, 11?", "en": "Which number does not fit: 2, 3, 5, 7, 9, 11?"},
    "mvp-007": {"ru": "Часы показывают 3:15. Каков меньший угол между стрелками?", "en": "The clock shows 3:15. What is the smaller angle between the hands?"},
    "mvp-008": {"ru": "Две двери ведут к безопасности и опасности. Один страж всегда лжет, другой всегда говорит правду. Можно задать одному стражу один вопрос. Как определить безопасную дверь?", "en": "Two doors lead to safety and danger. One guard always lies and the other always tells the truth. You may ask one guard one question. How do you identify the safe door?"},
    "mvp-009": {"ru": "Все шесть граней куба окрашены, затем его разрезали на 27 равных кубиков. Сколько кубиков имеют ровно две окрашенные грани?", "en": "All six faces of a cube are painted, then it is cut into 27 equal cubes. How many have exactly two painted faces?"},
    "mvp-010": {"ru": "В задаче сказано: Нажмите зеленую кнопку, чтобы продолжить. Зеленая кнопка отключена. Что проверить сначала?", "en": "The task says: Press the green button to continue. The green button is disabled. What should you check first?"}
}

static func get(puzzle_id: String, language: String, fallback: String) -> String:
    if not TEXTS.has(puzzle_id):
        return fallback
    var translations = TEXTS[puzzle_id]
    if translations is Dictionary and translations.has(language):
        return str(translations[language])
    return fallback
