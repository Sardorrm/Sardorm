extends Node

const RESET_BUTTON_TEXT := "PROGRESSNI TOZALASH"
var guarded_buttons: Dictionary = {}

func _ready() -> void:
    get_tree().node_added.connect(_on_node_added)
    _scan_existing_buttons()

func _scan_existing_buttons() -> void:
    var root := get_tree().current_scene
    if root == null:
        return
    for node in root.find_children("*", "Button", true, false):
        _guard_if_reset_button(node)

func _on_node_added(node: Node) -> void:
    _guard_if_reset_button(node)

func _guard_if_reset_button(node: Node) -> void:
    if not (node is Button) or node.text != RESET_BUTTON_TEXT:
        return
    var button := node as Button
    var button_id := button.get_instance_id()
    if guarded_buttons.has(button_id):
        return
    _guard_reset_button(button)
    guarded_buttons[button_id] = true

func _guard_reset_button(button: Button) -> void:
    for connection in button.pressed.get_connections():
        var callback: Callable = connection.get("callable", Callable())
        if callback.is_valid() and callback.get_method() == "_reset_progress":
            button.pressed.disconnect(callback)
    button.pressed.connect(_confirm_reset)

func _confirm_reset() -> void:
    var root := get_tree().current_scene
    if root == null:
        return
    var dialog := ConfirmationDialog.new()
    dialog.title = "Progressni tozalash"
    dialog.dialog_text = "Barcha progress, yutuqlar, daily natijalari va saqlangan sozlamalar o‘chiriladi. Davom etasizmi?"
    dialog.ok_button_text = "TOZALASH"
    dialog.cancel_button_text = "BEKOR QILISH"
    root.add_child(dialog)
    dialog.confirmed.connect(func():
        SaveManager.clear_progress()
        get_tree().reload_current_scene()
        dialog.queue_free()
    )
    dialog.canceled.connect(dialog.queue_free)
    dialog.popup_centered_ratio(0.82)
