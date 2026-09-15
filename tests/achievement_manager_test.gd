extends SceneTree

func _init() -> void:
    var manager := AchievementManager.new()

    var first := manager.on_solved(1, false)
    assert(first == ["first_step"])
    assert(manager.is_unlocked("first_step"))

    var duplicate := manager.on_solved(1, false)
    assert(duplicate.is_empty())
    assert(manager.unlocked.count("first_step") == 1)

    for total in range(2, 11):
        manager.on_solved(total, false)
    assert(manager.is_unlocked("ten_solved"))
    assert(manager.hints_free_solved == 10)

    manager.on_failed()
    assert(manager.streak == 0)

    var daily_3 := manager.on_daily_completed(3)
    assert(daily_3 == ["daily_3"])
    var daily_repeat := manager.on_daily_completed(3)
    assert(daily_repeat.is_empty())

    var daily_7 := manager.on_daily_completed(7)
    assert(daily_7 == ["daily_7"])

    var persisted := manager.to_dict()
    var restored := AchievementManager.new()
    restored.load_from_dict(persisted)
    assert(restored.unlocked == manager.unlocked)
    assert(restored.streak == manager.streak)
    assert(restored.hints_free_solved == manager.hints_free_solved)

    print("Achievement manager contract: PASS")
    quit(0)
