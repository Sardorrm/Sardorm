extends Node

const TIMER_WARNING_SECONDS := 10
const TIMER_CRITICAL_SECONDS := 5
const LEVEL_BUTTON_SIZE := Vector2(76, 64)
const BASE_MARGIN_LEFT := 24.0
const BASE_MARGIN_RIGHT := 24.0
const BASE_MARGIN_TOP := 28.0
const BASE_MARGIN_BOTTOM := 28.0
const HAPTIC_MS := 18
var pulse_time := 0.0
var styled_nodes: Dictionary = {}
var haptics_enabled := true
var active_timer_label: Label
var _ui: Control
var _margin: MarginContainer
var _last_ui_size := Vector2.ZERO
var _last_screen_size := Vector2i.ZERO

func _ready() -> void:
    get_tree().node_added.connect(_on_node_added)
    get_tree().node_removed.connect(_on_node_removed)
    call_deferred("_refresh_current_scene")

func set_haptics_enabled(enabled: bool) -> void:
    haptics_enabled = enabled

func _process(delta: float) -> void:
    pulse_time += delta
    if not is_instance_valid(_ui) or not _ui.is_inside_tree():
        _ui = null
        _margin = null
        return
    _refresh_safe_area_if_needed()
    if is_instance_valid(active_timer_label) and active_timer_label.is_inside_tree():
        _polish_timer(active_timer_label)
    else:
        active_timer_label = null

func _on_node_added(node: Node) -> void:
    _apply_static_polish(node)
    if node is Control:
        _bind_ui_nodes(node)
    if node is Label:
        var label := node as Label
        if label.text.begins_with("⏱"):
            active_timer_label = label
            _polish_timer(label)
        elif label.text.begins_with("✓ TO‘G‘RI") or label.text.begins_with("Hali emas") or label.text.begins_with("⏱ VAQT TUGADI"):
            _polish_feedback(label)
    if node is Control:
        call_deferred("_refresh_current_scene")

func _on_node_removed(node: Node) -> void:
    if node == active_timer_label:
        active_timer_label = null
    if node == _margin:
        _margin = null
    if node == _ui:
        _ui = null
        _margin = null
    styled_nodes.erase(node.get_instance_id())

func _refresh_current_scene() -> void:
    var root := get_tree().current_scene
    if root == null:
        return
    _bind_ui_nodes(root)
    _polish_tree_once(root)
    _refresh_safe_area_if_needed(true)

func _bind_ui_nodes(node: Node) -> void:
    if node.name == "Control" and node is Control:
        _ui = node as Control
        _margin = _ui.get_node_or_null("MarginContainer") as MarginContainer

func _polish_tree_once(node: Node) -> void:
    _apply_static_polish(node)
    if node is Label:
        var label := node as Label
        if label.text.begins_with("⏱"):
            active_timer_label = label
            _polish_timer(label)
        elif label.text.begins_with("✓ TO‘G‘RI") or label.text.begins_with("Hali emas") or label.text.begins_with("⏱ VAQT TUGADI"):
            _polish_feedback(label)
    for child in node.get_children():
        _polish_tree_once(child)

func _refresh_safe_area_if_needed(force := false) -> void:
    if not is_instance_valid(_ui) or not is_instance_valid(_margin):
        return
    var screen := DisplayServer.screen_get_size(DisplayServer.SCREEN_OF_MAIN_WINDOW)
    if not force and _ui.size == _last_ui_size and screen == _last_screen_size:
        return
    _last_ui_size = _ui.size
    _last_screen_size = screen
    _apply_safe_area()

func _apply_safe_area() -> void:
    if not is_instance_valid(_ui) or not is_instance_valid(_margin):
        return
    var left := BASE_MARGIN_LEFT
    var right := BASE_MARGIN_RIGHT
    var top := BASE_MARGIN_TOP
    var bottom := BASE_MARGIN_BOTTOM
    if OS.has_feature("android") or OS.has_feature("ios"):
        var safe := DisplayServer.get_display_safe_area()
        var screen := DisplayServer.screen_get_size(DisplayServer.SCREEN_OF_MAIN_WINDOW)
        if safe.size.x > 0 and safe.size.y > 0 and screen.x > 0 and screen.y > 0:
            var scale := Vector2(_ui.size.x / float(screen.x), _ui.size.y / float(screen.y))
            left += maxf(0.0, float(safe.position.x) * scale.x)
            top += maxf(0.0, float(safe.position.y) * scale.y)
            var safe_right := float(screen.x - safe.end.x) * scale.x
            var safe_bottom := float(screen.y - safe.end.y) * scale.y
            right += maxf(0.0, safe_right)
            bottom += maxf(0.0, safe_bottom)
    _margin.add_theme_constant_override("margin_left", roundi(left))
    _margin.add_theme_constant_override("margin_right", roundi(right))
    _margin.add_theme_constant_override("margin_top", roundi(top))
    _margin.add_theme_constant_override("margin_bottom", roundi(bottom))

func _apply_static_polish(node: Node) -> void:
    var node_id := node.get_instance_id()
    if styled_nodes.has(node_id):
        return
    styled_nodes[node_id] = true
    if node is Button:
        _polish_button(node)
    elif node is LineEdit:
        node.custom_minimum_size.y = maxf(node.custom_minimum_size.y, 60.0)
        node.add_theme_font_size_override("font_size", 21)

func _polish_button(button: Button) -> void:
    button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, 58.0)
    button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    if not button.pressed.is_connected(_on_button_pressed):
        button.pressed.connect(_on_button_pressed)
    if button.get_parent() is GridContainer:
        _polish_level_button(button)
    elif button.text == "TEKSHIRISH" or button.text == "KEYINGI DARAJA" or button.text == "KEYINGISI":
        button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, 68.0)

func _polish_level_button(button: Button) -> void:
    button.custom_minimum_size = LEVEL_BUTTON_SIZE
    button.add_theme_font_size_override("font_size", 18)
    var level_text := button.text.replace(" ✓", "").strip_edges()
    var level := int(level_text) if level_text.is_valid_int() else 0
    if button.disabled:
        button.tooltip_text = "🔒 Bu daraja hali ochilmagan"
    elif button.text.ends_with("✓"):
        button.tooltip_text = "✓ Yechilgan daraja %d" % level
    else:
        button.tooltip_text = "Daraja %d" % level

func _on_button_pressed() -> void:
    if haptics_enabled and (OS.has_feature("android") or OS.has_feature("ios")):
        Input.vibrate_handheld(HAPTIC_MS, 0.25)

func _polish_timer(label: Label) -> void:
    var seconds := _extract_timer_seconds(label.text)
    if seconds <= TIMER_CRITICAL_SECONDS:
        var pulse := 1.0 + sin(pulse_time * 7.0) * 0.08
        label.scale = Vector2(pulse, pulse)
        label.add_theme_color_override("font_color", Color("ff6b6b"))
    elif seconds <= TIMER_WARNING_SECONDS:
        label.scale = Vector2.ONE
        label.add_theme_color_override("font_color", Color("ffc857"))
    else:
        label.scale = Vector2.ONE
        label.remove_theme_color_override("font_color")

func _polish_feedback(label: Label) -> void:
    label.custom_minimum_size.y = maxf(label.custom_minimum_size.y, 62.0)
    label.add_theme_font_size_override("font_size", 20)

func _extract_timer_seconds(text: String) -> int:
    var cleaned := text.replace("⏱", "").replace("s", "").strip_edges()
    return int(cleaned)
