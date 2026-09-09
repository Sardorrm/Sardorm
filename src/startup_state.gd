class_name StartupState
extends CanvasLayer

const OVERLAY_NAME := "StartupStateOverlay"
const MESSAGE_COLOR := Color("f1f3ff")
const BACKGROUND_COLOR := Color("0b0b12")

var overlay: Control
var message: Label
var retry_button: Button
var _main_ready := false

func _ready() -> void:
    layer = 100
    _build_loading_state()
    call_deferred("_watch_main_startup")

func mark_main_ready() -> void:
    _main_ready = true
    _hide_overlay()

func show_error(title: String, detail: String, retry_callback: Callable = Callable()) -> void:
    _main_ready = false
    _build_error_state(title, detail, retry_callback)

func show_empty(title: String, detail: String, back_callback: Callable = Callable()) -> void:
    _main_ready = false
    _build_empty_state(title, detail, back_callback)

func _build_loading_state() -> void:
    _ensure_overlay()
    message.text = "MindShift\nYuklanmoqda..."
    message.add_theme_font_size_override("font_size", 24)
    retry_button.visible = false
    overlay.visible = true

func _build_error_state(title: String, detail: String, retry_callback: Callable) -> void:
    _ensure_overlay()
    message.text = "%s\n\n%s" % [title, detail]
    message.add_theme_font_size_override("font_size", 22)
    retry_button.visible = true
    retry_button.text = "QAYTA URINISH"
    for connection in retry_button.pressed.get_connections():
        retry_button.pressed.disconnect(connection.callable)
    if retry_callback.is_valid():
        retry_button.pressed.connect(retry_callback)
    else:
        retry_button.pressed.connect(func(): get_tree().reload_current_scene())
    overlay.visible = true

func _build_empty_state(title: String, detail: String, back_callback: Callable) -> void:
    _ensure_overlay()
    message.text = "%s\n\n%s" % [title, detail]
    message.add_theme_font_size_override("font_size", 22)
    retry_button.visible = back_callback.is_valid()
    retry_button.text = "ORTGA"
    for connection in retry_button.pressed.get_connections():
        retry_button.pressed.disconnect(connection.callable)
    if back_callback.is_valid():
        retry_button.pressed.connect(back_callback)
    overlay.visible = true

func _ensure_overlay() -> void:
    if overlay != null and is_instance_valid(overlay):
        return
    overlay = Control.new()
    overlay.name = OVERLAY_NAME
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(overlay)

    var background := ColorRect.new()
    background.color = BACKGROUND_COLOR
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    overlay.add_child(background)

    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    overlay.add_child(center)

    var panel := VBoxContainer.new()
    panel.custom_minimum_size = Vector2(280, 0)
    panel.add_theme_constant_override("separation", 18)
    center.add_child(panel)

    message = Label.new()
    message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    message.add_theme_color_override("font_color", MESSAGE_COLOR)
    panel.add_child(message)

    retry_button = Button.new()
    retry_button.custom_minimum_size = Vector2(0, 64)
    retry_button.focus_mode = Control.FOCUS_ALL
    panel.add_child(retry_button)

func _watch_main_startup() -> void:
    await get_tree().process_frame
    if _main_ready:
        return
    var main := get_tree().current_scene
    if main != null and main.get_child_count() > 0:
        for child in main.get_children():
            if child is Control:
                mark_main_ready()
                return
    await get_tree().create_timer(1.0).timeout
    if _main_ready:
        return
    var scene := get_tree().current_scene
    if scene != null and scene.get_child_count() > 0:
        for child in scene.get_children():
            if child is Control:
                mark_main_ready()
                return
    show_error("MindShift ishga tushmadi", "Asosiy interfeys yuklanmadi. Qayta urinib ko‘ring.")

func _hide_overlay() -> void:
    if overlay != null and is_instance_valid(overlay):
        overlay.visible = false
