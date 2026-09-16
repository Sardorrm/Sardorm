class_name PuzzleTranslations
extends RefCounted

const TEXTS := {
    "mvp-001": {"ru": "Какое число следующее? 2, 4, 8, 16, ?", "en": "What number comes next? 2, 4, 8, 16, ?"},
    "mvp-002": {"ru": "В коробке 3 красных и 3 синих шара. Сколько шаров минимум нужно взять вслепую, чтобы гарантированно получить два одного цвета?", "en": "A box has 3 red and 3 blue balls. What is the minimum number to draw blind to guarantee two of the same color?"},
    "mvp-003": {"ru": "Что дальше? 1, 1, 2, 3, 5, 8, ?", "en": "What comes next? 1, 1, 2, 3, 5, 8, ?"},
    "mvp-004": {"ru": "У вас одна спичка. В темной комнате есть свеча, масляная лампа и камин. Что вы зажжете первым?", "en": "You have one match. In a dark room are a candle, oil lamp and fireplace. What do you light first?"},
    "mvp-005": {"ru": "У фермера 17 овец. Все, кроме 9, убежали. Сколько осталось?", "en": "A farmer has 17 sheep. All but 9 run away. How many remain?"},
    "mvp-006": {"ru": "Какое число лишнее: 2, 3, 5, 7, 9, 11?", "en": "Which number does not fit: 2, 3, 5, 7, 9, 11?"},
    "mvp-007": {"ru": "Часы показывают 3:15. Каков меньший угол между стрелками?", "en": "The clock shows 3:15. What is the smaller angle between the hands?"},
    "mvp-008": {"ru": "Две двери ведут к безопасности и опасности. Один страж всегда лжет, другой всегда говорит правду. Можно задать одному стражу один вопрос. Как определить безопасную дверь?", "en": "Two doors lead to safety and danger. One guard always lies and the other always tells the truth. You may ask one guard one question. How do you identify the safe door?"},
    "mvp-009": {"ru": "Все шесть граней куба окрашены, затем его разрезали на 27 равных кубиков. Сколько кубиков имеют ровно две окрашенные грани?", "en": "All six faces of a cube are painted, then it is cut into 27 equal cubes. How many have exactly two painted faces?"},
    "mvp-010": {"ru": "В задаче сказано: Нажмите зеленую кнопку, чтобы продолжить. Зеленая кнопка отключена. Что проверить сначала?", "en": "The task says: Press the green button to continue. The green button is disabled. What should you check first?"},
    "mvp-011": {"ru": "Какое число следующее? 5, 10, 15, 20, ?", "en": "What number comes next? 5, 10, 15, 20, ?"},
    "mvp-012": {"ru": "Какое число следующее? 1, 4, 9, 16, ?", "en": "What number comes next? 1, 4, 9, 16, ?"},
    "mvp-013": {"ru": "У вас 10 яблок, и вы отдаете 3. Сколько яблок осталось?", "en": "You have 10 apples and give 3 away. How many apples are left?"},
    "mvp-014": {"ru": "Самолет терпит крушение точно на границе двух стран. Где хоронить выживших?", "en": "A plane crashes exactly on the border between two countries. Where do you bury the survivors?"},
    "mvp-015": {"ru": "Какое слово отличается: CAT, DOG, COW, CAR, HORSE?", "en": "Which word is different: CAT, DOG, COW, CAR, HORSE?"},
    "mvp-016": {"ru": "Что дальше? 20, 18, 15, 11, ?", "en": "What comes next? 20, 18, 15, 11, ?"},
    "mvp-017": {"ru": "В комнате 4 угла. В каждом углу сидит одна кошка. Каждая кошка видит 3 кошек. Сколько кошек в комнате?", "en": "A room has 4 corners. In each corner sits one cat. Each cat sees 3 cats. How many cats are in the room?"},
    "mvp-018": {"ru": "Куб окрашен со всех внешних сторон и разрезан на 8 равных кубиков. Сколько маленьких кубиков имеют ровно три окрашенные грани?", "en": "A cube is painted on every outside face and cut into 8 equal cubes. How many small cubes have exactly three painted faces?"},
    "mvp-019": {"ru": "У фермера есть куры и коровы. Всего 10 голов и 28 ног. Сколько коров?", "en": "A farmer has chickens and cows. There are 10 heads and 28 legs. How many cows are there?"},
    "mvp-020": {"ru": "Вам сказали: следующий ответ не равен 5. Какое число безопаснее всего проверить первым, если другой информации нет?", "en": "You are told: The next answer is not 5. Which number is safe to test first if there is no other information?"},
    "mvp-021": {"ru": "Какое число следующее? 3, 6, 12, 24, ?", "en": "What number comes next? 3, 6, 12, 24, ?"},
    "mvp-022": {"ru": "Что дальше? 2, 3, 5, 8, 12, ?", "en": "What comes next? 2, 3, 5, 8, 12, ?"},
    "mvp-023": {"ru": "Пять машин делают пять предметов за пять минут. Сколько минут потребуется 100 машинам, чтобы сделать 100 предметов с той же скоростью?", "en": "Five machines make five items in five minutes. How many minutes would 100 machines take to make 100 items at the same rate?"},
    "mvp-024": {"ru": "Мужчина бреется несколько раз в день, но у него все еще есть борода. Кто он?", "en": "A man shaves several times a day but still has a beard. Who is he?"},
    "mvp-025": {"ru": "Если вы обгоняете человека, занимающего второе место в гонке, какое место занимаете вы?", "en": "If you overtake the person in second place in a race, what place are you in?"},
    "mvp-026": {"ru": "Большой куб разделен на 3×3×3 маленьких кубика. Сколько маленьких кубиков не имеют окрашенных граней, если окрашена только внешняя поверхность?", "en": "A large cube is divided into 3×3×3 small cubes. How many small cubes have no painted faces if only the outside is painted?"},
    "mvp-027": {"ru": "Есть две веревки. Каждая горит ровно один час, но неравномерно. Как измерить ровно 30 минут?", "en": "You have two ropes. Each rope takes exactly one hour to burn, but burns unevenly. How can you measure exactly 30 minutes?"},
    "mvp-028": {"ru": "На запертом ящике написано: «Ключ внутри этого ящика». Какое первое предположение нужно поставить под сомнение?", "en": "A locked box has a sign saying: The key is inside this box. What is the first assumption you should question?"},
    "mvp-029": {"ru": "Какое число следующее? 1, 2, 6, 24, 120, ?", "en": "What number comes next? 1, 2, 6, 24, 120, ?"},
    "mvp-030": {"ru": "В темной комнате есть свеча, плита и лампа, а также одна спичка. Что вы зажжете первым?", "en": "You have a candle, a stove and a lamp in a dark room, plus one match. What do you light first?"}
}

static func get(puzzle_id: String, language: String, fallback: String) -> String:
    if not TEXTS.has(puzzle_id):
        return fallback
    var translations = TEXTS[puzzle_id]
    if typeof(translations) == TYPE_DICTIONARY:
        return str(translations.get(language, fallback))
    return fallback
