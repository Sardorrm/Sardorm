extends SceneTree

func _init() -> void:
    _assert_migration("v1 legacy", {"version": 1, "current_level": 4, "completed": [3, 1, 1, -2], "hints_used": 2, "settings": {"sound": false, "language": "UZ"}}, 4, [1, 3], 2, 3, "uz")
    _assert_migration("v3 with streak but no lives", {"version": 3, "current_level": 8, "completed_levels": [8, 2, 2], "streak": {"current_streak": 2}}, 8, [2, 8], 0, 3, "uz")
    _assert_migration("v5 with invalid settings", {"version": 5, "current_level": -1, "completed_levels": "bad", "settings": {"language": "xx", "sound": 0, "haptics": 1}}, 0, [], 0, 3, "uz")
    var current := SaveManager.migrate_data({"version": 6, "current_level": 9, "completed_levels": [9], "settings": {"language": "ru"}})
    assert(current.version == SaveManager.SAVE_VERSION)
    assert(current.current_level == 9)
    assert(current.settings.language == "ru")
    print("Save migration contract: PASS (legacy v1/v3/v5 + current v6)")
    quit(0)

func _assert_migration(label: String, source: Dictionary, expected_level: int, expected_completed: Array, expected_hints: int, expected_lives: int, expected_language: String) -> void:
    var result := SaveManager.migrate_data(source)
    assert(result.version == SaveManager.SAVE_VERSION, label)
    assert(result.current_level == expected_level, label)
    assert(result.completed_levels == expected_completed, label)
    assert(result.hints_used == expected_hints, label)
    assert(int(result.lives.get("lives", -1)) == expected_lives, label)
    assert(str(result.settings.get("language", "")) == expected_language, label)
