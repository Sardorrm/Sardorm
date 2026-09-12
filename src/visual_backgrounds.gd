extends Node

const DEFAULT_BG := "res://assets/backgrounds/mindshift_cognitive_bg.svg"
const CATEGORY_BGS := {
    "PATTERN": "res://assets/backgrounds/patterns.svg",
    "LOGIC": "res://assets/backgrounds/logic.svg",
    "OBSERVATION": "res://assets/backgrounds/observation.svg",
    "SPATIAL": "res://assets/backgrounds/spatial.svg",
    "ASSUMPTION": "res://assets/backgrounds/assumption.svg",
    "MINDSHIFT": "res://assets/backgrounds/mindshift_reality.svg"
}
var _background: TextureRect
var _installed := false

func _ready() -> void:
    get_tree().node_added.connect(_on_node_added)
    call_deferred("_try_install")

func _on_node_added(node: Node) -> void:
    call_deferred("_try_install")
    if node is Label:
        call_deferred("_update_from_label", node)

func _try_install() -> void:
    if _installed:
        return
    var scene := get_tree().current_scene
    if scene == null:
        return
    var ui := scene.find_child("Control", true, false) as Control
    if ui == null:
        return
    var existing := ui.find_child("MindShiftVisualBackground", true, false) as TextureRect
    if existing != null:
        _background = existing
        _installed = true
        return
    _background = _make_background(ui, DEFAULT_BG)
    if _background != null:
        _installed = true

func _make_background(ui: Control, path: String) -> TextureRect:
    var texture := load(path) as Texture2D
    if texture == null:
        return null
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
    return background

func _update_from_label(node: Label) -> void:
    if not _installed or not is_instance_valid(_background):
        return
    var text := node.text.to_upper()
    for category in CATEGORY_BGS:
        if text.begins_with(category + "  •") or text.begins_with(category + " •"):
            _set_background(CATEGORY_BGS[category])
            return

func _set_background(path: String) -> void:
    var texture := load(path) as Texture2D
    if texture != null and is_instance_valid(_background):
        _background.texture = texture
