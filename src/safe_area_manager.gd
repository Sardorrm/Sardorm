class_name SafeAreaManager
extends Node

const MIN_MARGIN := 20
const CONTENT_GAP := 16

var _refresh_pending := false

func _ready() -> void:
    get_viewport().size_changed.connect(_queue_refresh)
    get_tree().node_added.connect(_on_node_added)
    _queue_refresh()

func _on_node_added(node: Node) -> void:
    if node is Control:
        _queue_refresh()

func _queue_refresh() -> void:
    if _refresh_pending:
        return
    _refresh_pending = true
    call_deferred("_refresh")

func _refresh() -> void:
    _refresh_pending = false
    var shell := get_tree().current_scene
    if shell == null:
        return
    var target := shell.find_child("SafeAreaShell", true, false)
    if target is MarginContainer:
        _apply_margins(target)

func _apply_margins(container: MarginContainer) -> void:
    var viewport_size := get_viewport().get_visible_rect().size
    if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
        return
    var safe := DisplayServer.get_display_safe_area()
    var left := clampi(int(safe.position.x), 0, int(viewport_size.x))
    var top := clampi(int(safe.position.y), 0, int(viewport_size.y))
    var right := clampi(int(viewport_size.x - safe.end.x), 0, int(viewport_size.x))
    var bottom := clampi(int(viewport_size.y - safe.end.y), 0, int(viewport_size.y))
    container.add_theme_constant_override("margin_left", maxi(MIN_MARGIN, left + CONTENT_GAP))
    container.add_theme_constant_override("margin_top", maxi(MIN_MARGIN, top + CONTENT_GAP))
    container.add_theme_constant_override("margin_right", maxi(MIN_MARGIN, right + CONTENT_GAP))
    container.add_theme_constant_override("margin_bottom", maxi(MIN_MARGIN, bottom + CONTENT_GAP))
