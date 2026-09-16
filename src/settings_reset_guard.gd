extends Node

const RESET_BUTTON_TEXT = "PROGRESSNI TOZALASH"
var guarded_buttons = {}

func _ready():
    get_tree().node_added.connect(_on_node_added)
    get_tree().node_removed.connect(_on_node_removed)
    call_deferred("_scan_existing_buttons")

func _scan_existing_buttons():
    var root = get_tree().current_scene
    if root == null:
        return
    for node in root.find_children("*", "Button", true, false):
        _guard_if_reset_button(node)

func _on_node_added(node):
    _guard_if_reset_button(node)

func _on_node_removed(node):
    if node != null:
        guarded_buttons.erase(node.get_instance_id())

func _guard_if_reset_button(node):
    if not (node is Button):
        return
    var button = node as Button
    if button.text != RESET_BUTTON_TEXT:
        return
    var button_id = button.get_instance_id()
    if guarded_buttons.has(button_id):
        return
    if button.pressed.is_connected(_confirm_reset):
        guarded_buttons[button_id] = true
        return
    button.pressed.connect(_confirm_reset)
    guarded_buttons[button_id] = true

func _confirm_reset():
    var root = get_tree().current_scene
    if root == null:
        return
    var dialog = ConfirmationDialog.new()
    dialog.title = "Progressni tozalash"
    dialog.dialog_text = "Barcha progress, yutuqlar, daily natijalari va saqlangan sozlamalar o‘chiriladi. Davom etasizmi?"
    dialog.ok_button_text = "TOZALASH"
    dialog.cancel_button_text = "BEKOR QILISH"
    root.add_child(dialog)
    dialog.confirmed.connect(_on_reset_confirmed.bind(dialog))
    dialog.canceled.connect(dialog.queue_free)
    dialog.popup_centered_ratio(0.82)

func _on_reset_confirmed(dialog):
    SaveManager.clear_progress()
    get_tree().reload_current_scene()
    if dialog != null and is_instance_valid(dialog):
        dialog.queue_free()
