extends Node

const BG_PATH := "res://assets/backgrounds/mindshift_cognitive_bg.svg"
var _installed := false

func _ready() -> void:
    get_tree().node_added.connect(_on_node_added)
    call_deferred("_try_install")

func _on_node_added(_node: Node) -> void:
    call_deferred("_try_install")

func _try_install() -> void:
    if _installed:
        return
    var scene := get_tree().current_scene
    if scene == null:
        return
    var ui := scene.find_child("Control", true, false) as Control
    if ui == null:
        return
    if ui.find_child("MindShiftVisualBackground", true, false) != null:
        _installed = true
        return
    var texture := load(BG_PATH) as Texture2D
    if texture == null:
        return
    var background := TextureRect.new()
    background.name = "MindShiftVisualBackground"
    background.texture = texture
    background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    background.z_index = -10
    ui.add_child(background)
    ui.move_child(background, 0)
    _installed = true
