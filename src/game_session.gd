class_name GameSession
extends RefCounted

signal state_changed(state: String)
signal answer_evaluated(correct: bool, elapsed_seconds: float)
signal attempt_failed(attempts: int)
signal timed_out(elapsed_seconds: float)

const STATE_IDLE := "idle"
const STATE_ACTIVE := "active"
const STATE_SOLVED := "solved"
const STATE_FAILED := "failed"
const STATE_TIMEOUT := "timeout"

var state := STATE_IDLE
var puzzle: PuzzleDefinition
var started_at_msec: int = 0
var attempts: int = 0
var hints_used: int = 0
var last_answer: String = ""
var time_limit_seconds := 0.0
var timeout_recorded := false
var paused := false
var paused_at_msec: int = 0
var paused_total_msec: int = 0

func start(new_puzzle: PuzzleDefinition, fallback_time_limit: float = 0.0) -> bool:
    if new_puzzle == null:
        reset()
        return false
    puzzle = new_puzzle
    started_at_msec = Time.get_ticks_msec()
    attempts = 0
    hints_used = 0
    last_answer = ""
    time_limit_seconds = max(0.0, new_puzzle.time_limit_seconds)
    if time_limit_seconds <= 0.0:
        time_limit_seconds = max(0.0, fallback_time_limit)
    timeout_recorded = false
    paused = false
    paused_at_msec = 0
    paused_total_msec = 0
    _set_state(STATE_ACTIVE)
    return true

func submit(answer: String) -> bool:
    if state != STATE_ACTIVE or puzzle == null or paused:
        return false
    if check_timeout():
        return false
    attempts += 1
    last_answer = answer
    var correct := _matches_answer(answer)
    var elapsed := get_elapsed_seconds()
    if correct:
        _set_state(STATE_SOLVED)
    else:
        _set_state(STATE_FAILED)
        attempt_failed.emit(attempts)
        _set_state(STATE_ACTIVE)
    answer_evaluated.emit(correct, elapsed)
    return correct

func timeout() -> bool:
    if state != STATE_ACTIVE or timeout_recorded or paused:
        return false
    timeout_recorded = true
    _set_state(STATE_TIMEOUT)
    timed_out.emit(get_elapsed_seconds())
    return true

func use_hint() -> bool:
    if state != STATE_ACTIVE or puzzle == null or hints_used > 0 or paused:
        return false
    hints_used = 1
    return true

func pause() -> bool:
    if state != STATE_ACTIVE or paused:
        return false
    paused = true
    paused_at_msec = Time.get_ticks_msec()
    return true

func resume() -> bool:
    if not paused:
        return false
    var now := Time.get_ticks_msec()
    paused_total_msec += maxi(0, now - paused_at_msec)
    paused_at_msec = 0
    paused = false
    return true

func check_timeout() -> bool:
    if state != STATE_ACTIVE or paused or time_limit_seconds <= 0.0 or timeout_recorded:
        return false
    if get_elapsed_seconds() < time_limit_seconds:
        return false
    return timeout()

func get_elapsed_seconds() -> float:
    if started_at_msec <= 0:
        return 0.0
    var effective_now := paused_at_msec if paused else Time.get_ticks_msec()
    return max(0.0, float(effective_now - started_at_msec - paused_total_msec) / 1000.0)

func get_remaining_seconds() -> float:
    if time_limit_seconds <= 0.0:
        return -1.0
    return max(0.0, time_limit_seconds - get_elapsed_seconds())

func get_failed_attempts() -> int:
    return attempts if state != STATE_SOLVED else max(0, attempts - 1)

func is_complete() -> bool:
    return state == STATE_SOLVED or state == STATE_TIMEOUT

func reset() -> void:
    puzzle = null
    started_at_msec = 0
    attempts = 0
    hints_used = 0
    last_answer = ""
    time_limit_seconds = 0.0
    timeout_recorded = false
    paused = false
    paused_at_msec = 0
    paused_total_msec = 0
    _set_state(STATE_IDLE)

func _matches_answer(value: String) -> bool:
    if puzzle == null:
        return false
    for expected in puzzle.get_answers():
        if expected is int or expected is float:
            var parsed := value.strip_edges().to_float()
            if is_finite(parsed) and abs(parsed - float(expected)) < 0.0001:
                return true
        elif _normalize(str(expected)) == _normalize(value):
            return true
    return false

func _normalize(value: String) -> String:
    var text := value.strip_edges().to_lower()
    while text.contains("  "):
        text = text.replace("  ", " ")
    return text

func _set_state(next_state: String) -> void:
    state = next_state
    state_changed.emit(state)
