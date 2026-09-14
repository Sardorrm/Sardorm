class_name MotionManager
extends Node

const PRESS_SCALE := Vector2(0.98, 0.98)
const PRESS_DURATION := 0.08

var reduced_motion := false
var bound_buttons: Dictionary = {}

func _ready() -> void:
    var data := SaveManager.load_progress()
    reduced_motion = bool(data.get("settings", {}).get("reduced_motion", false))
    get_tree().node_added.connect(_on_node_added)
    get_tree().node_removed.connect(_on_node_removed)
    call_deferred("_bind_tree")

func _bind_tree() -> void:
    var root := get_tree().current_scene
    if root != null:
        _bind_tree_node(root)

func _bind_tree_node(node: Node) -> void:
    _bind_button(node)
    for child in node.get_children():
        _bind_tree_node(child)

func _on_node_added(node: Node) -> void:
    _bind_button(node)

func _on_node_removed(node: Node) -> void:
    if bound_buttons.has(node.get_instance_id()):
        bound_buttons.erase(node.get_instance_id())

func _bind_button(node: Node) -> void:
    if not node is Button:
        return
    var button := node as Button
    var id := button.get_instance_id()
    if bound_buttons.has(id):
        return
    bound_buttons[id] = true
    button.button_down.connect(func(): _press_down(button))
    button.button_up.connect(func(): _press_up(button))

func _press_down(button: Button) -> void:
    if reduced_motion or not is_instance_valid(button):
        return
    var tween := button.create_tween()
    tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_property(button, "scale", PRESS_SCALE, PRESS_DURATION)

func _press_up(button: Button) -> void:
    if reduced_motion or not is_instance_valid(button):
        return
    var tween := button.create_tween()
    tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_property(button, "scale", Vector2.ONE, PRESS_DURATION)
