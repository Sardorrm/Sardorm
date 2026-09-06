class_name DailyChallenge
extends RefCounted

const CHALLENGE_SIZE := 3

static func date_key(unix_time: int = -1) -> String:
    var timestamp := unix_time if unix_time >= 0 else Time.get_unix_time_from_system()
    var dt := Time.get_datetime_dict_from_unix_time(timestamp)
    return "%04d-%02d-%02d" % [int(dt.year), int(dt.month), int(dt.day)]

static func seed_for_date(key: String) -> int:
    return abs(int(hash("mindshift-daily:" + key)))

static func select_indices(puzzle_count: int, key: String, count: int = CHALLENGE_SIZE) -> Array:
    if puzzle_count <= 0 or count <= 0:
        return []
    var target := mini(count, puzzle_count)
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_for_date(key)
    var pool: Array = range(puzzle_count)
    var selected: Array = []
    while selected.size() < target and not pool.is_empty():
        var position := rng.randi_range(0, pool.size() - 1)
        selected.append(pool[position])
        pool.remove_at(position)
    selected.sort()
    return selected

static func build(key: String, puzzle_count: int) -> Dictionary:
    return {"date": key, "seed": seed_for_date(key), "indices": select_indices(puzzle_count, key), "completed": false}
