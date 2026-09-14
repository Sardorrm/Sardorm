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
var _texture_cache: Dictionary = {}
var _last_category := ""

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
    var ui: Control = null
    for child in scene.get_children():
        if child is Control:
            ui = child as Control
            break
    if ui == null:
        ui = scene.find_child("Control", true, false) as Control
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
    var texture := _load_texture(path)
    if texture == null:
        return null
    var background := TextureRect.new()
    background.name = "MindShiftVisualBackground"
    background.texture = texture
    background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    background.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    background.z_index = -10
    ui.add_child(background)
    ui.move_child(background, 0)
    return background

func _update_from_label(node: Label) -> void:
    if not _installed or not is_instance_valid(_background):
        return
    var category := _category_from_label(node.text)
    if category.is_empty() or category == _last_category:
        return
    _last_category = category
    _set_background(CATEGORY_BGS[category])

func _category_from_label(value: String) -> String:
    var text := value.strip_edges().to_upper()
    for category in CATEGORY_BGS:
        if text.begins_with(category + "  •") or text.begins_with(category + " •"):
            return category
    return ""

func _set_background(path: String) -> void:
    var texture := _load_texture(path)
    if texture != null and is_instance_valid(_background):
        _background.texture = texture

func _load_texture(path: String) -> Texture2D:
    if _texture_cache.has(path):
        return _texture_cache[path] as Texture2D
    var texture := load(path) as Texture2D
    if texture != null:
        _texture_cache[path] = texture
    return texture
