extends Node

const TIMER_WARNING_SECONDS := 10
const TIMER_CRITICAL_SECONDS := 5
const LEVEL_BUTTON_SIZE := Vector2(76, 64)
const HAPTIC_MS := 18
var pulse_time := 0.0
var styled_nodes: Dictionary = {}
var haptics_enabled := true

func set_haptics_enabled(enabled: bool) -> void:
    haptics_enabled = enabled

func _process(delta: float) -> void:
    pulse_time += delta
    var root := get_tree().current_scene
    if root == null:
        return
    _polish_tree(root)

func _polish_tree(node: Node) -> void:
    var node_id := node.get_instance_id()
    if not styled_nodes.has(node_id):
        _apply_static_polish(node)
        styled_nodes[node_id] = true
    if node is Label and node.text.begins_with("⏱"):
        _polish_timer(node)
    elif node is Label and (node.text.begins_with("✓ TO‘G‘RI") or node.text.begins_with("Hali emas") or node.text.begins_with("⏱ VAQT TUGADI")):
        _polish_feedback(node)
    for child in node.get_children():
        _polish_tree(child)

func _apply_static_polish(node: Node) -> void:
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
