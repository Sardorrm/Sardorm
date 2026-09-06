extends RefCounted

func test_normalized_answer() -> void:
    var engine := PuzzleEngine.new()
    engine.puzzles = [{"answer": "42"}]
    assert(engine.check_answer(0, " 42 "))
    assert(not engine.check_answer(0, "41"))

func test_invalid_index() -> void:
    var engine := PuzzleEngine.new()
    engine.puzzles = []
    assert(engine.get_puzzle(0).is_empty())
