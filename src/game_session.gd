class_name GameSession
extends RefCounted

signal state_changed(state: String)
signal answer_evaluated(correct: bool, elapsed_seconds: float)

const STATE_IDLE := "idle"
const STATE_ACTIVE := "active"
const STATE_SOLVED := "solved"
const STATE_FAILED := "failed"

var state := STATE_IDLE
var puzzle: PuzzleDefinition
var started_at_msec: int = 0
var attempts: int = 0
var hints_used: int = 0
var last_answer: String = ""

func start(new_puzzle: PuzzleDefinition) -> bool:
    if new_puzzle == null:
        reset()
        return false
    puzzle = new_puzzle
    started_at_msec = Time.get_ticks_msec()
    attempts = 0
    hints_used = 0
    last_answer = ""
    _set_state(STATE_ACTIVE)
    return true

func submit(answer: String, engine: PuzzleEngine) -> bool:
    if state != STATE_ACTIVE or puzzle == null or engine == null:
        return false
    attempts += 1
    last_answer = answer
    var correct := _matches_answer(engine, answer)
    if correct:
        _set_state(STATE_SOLVED)
    else:
        _set_state(STATE_FAILED)
        _set_state(STATE_ACTIVE)
    answer_evaluated.emit(correct, get_elapsed_seconds())
    return correct

func use_hint() -> bool:
    if state != STATE_ACTIVE or puzzle == null or hints_used > 0:
        return false
    hints_used = 1
    return true

func get_elapsed_seconds() -> float:
    if started_at_msec <= 0:
        return 0.0
    return max(0.0, float(Time.get_ticks_msec() - started_at_msec) / 1000.0)

func is_complete() -> bool:
    return state == STATE_SOLVED

func reset() -> void:
    puzzle = null
    started_at_msec = 0
    attempts = 0
    hints_used = 0
    last_answer = ""
    _set_state(STATE_IDLE)

func _matches_answer(engine: PuzzleEngine, value: String) -> bool:
    var index := engine.puzzles.find(puzzle.to_dict())
    if index >= 0:
        return engine.check_answer(index, value)
    for expected in puzzle.get_answers():
        if str(expected).strip_edges().to_lower() == value.strip_edges().to_lower():
            return true
    return false

func _set_state(next_state: String) -> void:
    state = next_state
    state_changed.emit(state)
