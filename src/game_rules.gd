class_name GameRules
extends RefCounted

const MAX_LIVES := 3
const PASSING_SCORE := 1

static func calculate_score(difficulty: int, seconds: float, hint_used: bool, failed_attempts: int) -> int:
    var base := difficulty * 100
    var time_bonus := maxi(0, 300 - int(seconds * 10))
    var hint_penalty := 100 if hint_used else 0
    var failure_penalty := failed_attempts * 50
    var raw_score := maxi(PASSING_SCORE, base + time_bonus - hint_penalty - failure_penalty)
    return maxi(PASSING_SCORE, int(round(float(raw_score) * DifficultyManager.score_multiplier(difficulty))))

static func star_rating(difficulty: int, seconds: float, hint_used: bool, failed_attempts: int) -> int:
    if failed_attempts == 0 and not hint_used and seconds <= maxf(10.0, 35.0 - difficulty * 3.0):
        return 3
    if failed_attempts <= 1 and seconds <= maxf(15.0, 55.0 - difficulty * 3.0):
        return 2
    return 1

static func category_key(category: String) -> String:
    return category.strip_edges().to_lower()
