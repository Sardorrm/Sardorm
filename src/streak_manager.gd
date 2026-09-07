class_name StreakManager
extends RefCounted

var current_streak := 0
var best_streak := 0
var last_completed_date := ""

func load_from_dict(data: Dictionary) -> void:
    current_streak = max(0, int(data.get("current_streak", 0)))
    best_streak = max(current_streak, int(data.get("best_streak", 0)))
    last_completed_date = str(data.get("last_completed_date", ""))
    if not _is_valid_date_key(last_completed_date):
        last_completed_date = ""
        current_streak = 0
    _refresh_gap()

func record_daily_completion(date_key: String) -> void:
    if not _is_valid_date_key(date_key) or date_key == last_completed_date:
        return
    if last_completed_date.is_empty():
        current_streak = 1
    else:
        var previous := _date_to_day(last_completed_date)
        var current := _date_to_day(date_key)
        current_streak = current_streak + 1 if current == previous + 1 else 1
    best_streak = maxi(best_streak, current_streak)
    last_completed_date = date_key

func break_streak() -> void:
    current_streak = 0

func get_multiplier() -> float:
    if current_streak >= 7:
        return 2.0
    if current_streak >= 3:
        return 1.5
    return 1.0

func to_dict() -> Dictionary:
    return {"current_streak": current_streak, "best_streak": best_streak, "last_completed_date": last_completed_date}

func _refresh_gap() -> void:
    if last_completed_date.is_empty():
        return
    var today := DailyChallenge.date_key()
    if _date_to_day(today) > _date_to_day(last_completed_date) + 1:
        current_streak = 0

func _date_to_day(value: String) -> int:
    if not _is_valid_date_key(value):
        return -1
    var parts := value.split("-")
    var year := int(parts[0])
    var month := int(parts[1])
    var day := int(parts[2])
    return int(Time.get_unix_time_from_datetime_dict({"year": year, "month": month, "day": day, "hour": 0, "minute": 0, "second": 0, "weekday": 0, "dst": false}) / 86400)

func _is_valid_date_key(value: String) -> bool:
    if value.length() != 10 or value[4] != "-" or value[7] != "-":
        return false
    var parts := value.split("-")
    if parts.size() != 3:
        return false
    var year := int(parts[0])
    var month := int(parts[1])
    var day := int(parts[2])
    if str(year).length() != 4 or month < 1 or month > 12 or day < 1 or day > 31:
        return false
    return true
