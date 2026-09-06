extends SceneTree

func _init() -> void:
    var engine := PuzzleEngine.new()
    assert(engine.load_from_file("res://data/puzzles.json"))
    assert(engine.puzzles.size() >= 10)
    assert(engine.check_answer(0, "32"))
    assert(not engine.check_answer(0, "31"))
    print("PuzzleEngine tests passed")
    quit()
