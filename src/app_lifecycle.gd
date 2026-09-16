extends Node

var paused_by_lifecycle: bool = false

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_PAUSED:
        _pause_active_game()
    elif what == NOTIFICATION_APPLICATION_RESUMED:
        _resume_active_game()

func _pause_active_game() -> void:
    var main: Node = get_tree().current_scene
    if main == null or not main.has_method("_toggle_pause"):
        return
    var session = main.get("session")
    if session == null:
        return
    if session.state != GameSession.STATE_ACTIVE or session.paused:
        return
    main._toggle_pause()
    paused_by_lifecycle = true

func _resume_active_game() -> void:
    if not paused_by_lifecycle:
        return
    var main: Node = get_tree().current_scene
    if main != null and main.has_method("_toggle_pause"):
        var session = main.get("session")
        if session != null and session.state == GameSession.STATE_ACTIVE and session.paused:
            main._toggle_pause()
    paused_by_lifecycle = false
