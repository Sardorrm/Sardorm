extends SceneTree

func _init() -> void:
    var repository := PuzzleRepository.new()
    assert(repository.load_from_file("res://data/puzzles.json"))
    assert(repository.puzzles.size() >= 100)

    var service := DailyChallengeService.new()
    service.setup(repository, {})

    var today := DailyChallenge.date_key()
    var same_day_indices := DailyChallenge.select_indices(repository.puzzles.size(), today, 3)
    assert(same_day_indices == DailyChallenge.select_indices(repository.puzzles.size(), today, 3))
    assert(same_day_indices.size() == 3)
    assert(same_day_indices[0] < same_day_indices[1])
    assert(same_day_indices[1] < same_day_indices[2])

    service.completed_count = 2
    service.current_position = 2
    service.current_date = "2000-01-01"
    service.refresh()
    assert(service.current_date == today)
    assert(service.completed_count == 0)
    assert(service.current_position == 0)

    service.record_failed()
    assert(service.current_position == 0)
    service.record_solved()
    assert(service.current_position == 1)
    assert(service.completed_count == 1)

    # A partial session must survive an application restart on the same date.
    var partial_persisted := service.to_dict()
    var partial_restored := DailyChallengeService.new()
    partial_restored.setup(repository, {"daily_challenges": partial_persisted})
    assert(partial_restored.current_date == today)
    assert(partial_restored.completed_count == 1)
    assert(partial_restored.current_position == 1)
    assert(partial_restored.current_indices == same_day_indices)
    assert(partial_restored.get_puzzles().size() == 3)

    partial_restored.record_solved()
    partial_restored.record_solved()
    assert(partial_restored.is_session_completed())
    partial_restored.mark_completed()
    partial_restored.mark_completed()
    assert(partial_restored.get_completed_dates_count() == 1)

    var persisted := partial_restored.to_dict()
    var restored := DailyChallengeService.new()
    restored.setup(repository, {"daily_challenges": persisted})
    assert(restored.is_completed())
    assert(restored.completed_count == 3)
    assert(restored.current_position == 3)
    assert(restored.get_completed_dates_count() == 1)

    var sanitized := DailyChallengeService.new()
    sanitized.setup(repository, {
        "daily_challenges": {
            "completed_dates": ["2024-02-29", "2023-02-29", "2024-13-01", "bad", " 2024-02-29 "]
        }
    })
    assert(sanitized.completed_dates == ["2024-02-29"])

    print("Daily challenge service contract: PASS")
    quit(0)
