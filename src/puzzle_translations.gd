class_name PuzzleTranslations
extends RefCounted

const TEXTS := {
    "mvp-011": {"ru":"Какое число следующее? 5, 10, 15, 20, ?", "en":"What number comes next? 5, 10, 15, 20, ?"},
    "mvp-012": {"ru":"Какое число следующее? 1, 4, 9, 16, ?", "en":"What number comes next? 1, 4, 9, 16, ?"},
    "mvp-013": {"ru":"У вас 10 яблок, и вы отдали 3. Сколько осталось?", "en":"You have 10 apples and give away 3. How many remain?"},
    "mvp-014": {"ru":"Самолёт разбился точно на границе двух стран. Где похоронить выживших?", "en":"A plane crashes exactly on the border of two countries. Where do you bury the survivors?"},
    "mvp-015": {"ru":"Какое слово отличается: CAT, DOG, COW, CAR, HORSE?", "en":"Which word is different: CAT, DOG, COW, CAR, HORSE?"},
    "mvp-016": {"ru":"Что дальше? 20, 18, 15, 11, ?", "en":"What comes next? 20, 18, 15, 11, ?"},
    "mvp-017": {"ru":"В комнате 4 угла. В каждом углу сидит по одной кошке. Каждая кошка видит 3 кошек. Сколько кошек в комнате?", "en":"A room has 4 corners. One cat sits in each corner, and each cat sees 3 cats. How many cats are there?"},
    "mvp-018": {"ru":"Куб окрашен снаружи и разрезан на 8 равных кубиков. Сколько имеют ровно три окрашенные грани?", "en":"A cube is painted outside and cut into 8 equal cubes. How many have exactly three painted faces?"},
    "mvp-019": {"ru":"У фермера куры и коровы. Всего 10 голов и 28 ног. Сколько коров?", "en":"A farmer has chickens and cows. There are 10 heads and 28 legs. How many cows?"},
    "mvp-020": {"ru":"Вам сказали: «Следующий ответ не 5». Какое число безопасно проверить первым, если другой информации нет?", "en":"You are told: ‘The next answer is not 5.’ What number is safe to test first if there is no other information?"},
    "mvp-021": {"ru":"Какое число следующее? 3, 6, 12, 24, ?", "en":"What number comes next? 3, 6, 12, 24, ?"},
    "mvp-022": {"ru":"Что дальше? 2, 3, 5, 8, 12, ?", "en":"What comes next? 2, 3, 5, 8, 12, ?"},
    "mvp-023": {"ru":"Пять машин делают пять предметов за пять минут. За сколько минут 100 машин сделают 100 предметов с той же скоростью?", "en":"Five machines make five items in five minutes. How many minutes would 100 machines take to make 100 items at the same rate?"},
    "mvp-024": {"ru":"Мужчина бреется несколько раз в день, но у него всё равно есть борода. Кто он?", "en":"A man shaves several times a day but still has a beard. Who is he?"},
    "mvp-025": {"ru":"Если вы обгоняете человека, занявшего второе место в гонке, какое место занимаете?", "en":"If you pass the person in second place in a race, what place are you in?"},
    "mvp-026": {"ru":"Большой куб разделён на 3×3×3 маленьких кубика. Если окрашена только внешняя поверхность, сколько кубиков не имеют окрашенных граней?", "en":"A large cube is divided into 3×3×3 small cubes. If only the outside is painted, how many small cubes have no painted faces?"},
    "mvp-027": {"ru":"Есть две верёвки. Каждая горит ровно час, но неравномерно. Как отмерить ровно 30 минут?", "en":"You have two ropes. Each burns for exactly one hour but at an uneven rate. How can you measure exactly 30 minutes?"},
    "mvp-028": {"ru":"На запертом ящике написано: «Ключ внутри этого ящика». Какое предположение нужно поставить под сомнение первым?", "en":"A locked box says: ‘The key is inside this box.’ Which assumption should you question first?"},
    "mvp-029": {"ru":"Какое число следующее? 1, 2, 6, 24, 120, ?", "en":"What number comes next? 1, 2, 6, 24, 120, ?"},
    "mvp-030": {"ru":"В тёмной комнате есть свеча, плита, лампа и одна спичка. Что зажжёте первым?", "en":"In a dark room there is a candle, stove, lamp and one match. What do you light first?"}
}

static func get(puzzle_id: String, language: String, fallback: String) -> String:
    if not TEXTS.has(puzzle_id):
        return fallback
    var translations: Dictionary = TEXTS[puzzle_id]
    return str(translations.get(language, fallback))
