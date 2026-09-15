extends SceneTree

func _init() -> void:
    if not SaveManager.clear_progress():
        push_error("Could not clear save before roundtrip test")
        quit(1)
        return

    var saved := SaveManager.save_progress(
        12,
        [9, 3, 3, -1],
        2,
        {"correct": 7},
        {"first_steps": true},
        {"sound": false, "haptics": true, "language": "EN"},
        {"date": "2026-09-16", "solved": 2},
        {"lives": 1, "last_loss_unix": 12345},
        {"current_streak": 4, "best_streak": 7, "last_completed_date": "2026-09-15"}
    )
    if not saved:
        push_error("SaveManager.save_progress failed")
        quit(1)
        return

    var loaded := SaveManager.load_progress()
    assert(loaded.version == SaveManager.SAVE_VERSION)
    assert(loaded.current_level == 12)
    assert(loaded.completed_levels == [3, 9])
    assert(loaded.hints_used == 2)
    assert(loaded.stats.correct == 7)
    assert(loaded.achievements.first_steps == true)
    assert(loaded.settings.sound == false)
    assert(loaded.settings.haptics == true)
    assert(loaded.settings.language == "en")
    assert(loaded.daily_challenges.solved == 2)
    assert(loaded.lives.lives == 1)
    assert(loaded.streak.current_streak == 4)
    assert(loaded.streak.best_streak == 7)

    assert(SaveManager.clear_progress())
    print("Save roundtrip contract: PASS")
    quit(0)
