extends Node2D

var puzzles: Array = []
var current_index := 0

func _ready() -> void:
    _load_puzzles()
    _build_ui()

func _load_puzzles() -> void:
    var file := FileAccess.open("res://data/puzzles.json", FileAccess.READ)
    if file == null:
        push_error("Could not open puzzle data")
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("puzzles"):
        push_error("Invalid puzzle data")
        return
    puzzles = parsed["puzzles"]

func _build_ui() -> void:
    var background := ColorRect.new()
    background.color = Color("101018")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 32)
    margin.add_theme_constant_override("margin_right", 32)
    margin.add_theme_constant_override("margin_top", 48)
    margin.add_theme_constant_override("margin_bottom", 48)
    add_child(margin)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 24)
    margin.add_child(box)

    var title := Label.new()
    title.text = "MindShift"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 42)
    box.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "Don't just find the answer — change the way you think."
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    box.add_child(subtitle)

    var start := Button.new()
    start.text = "START"
    start.custom_minimum_size = Vector2(0, 72)
    start.add_theme_font_size_override("font_size", 24)
    start.pressed.connect(_start_game)
    box.add_child(start)

func _start_game() -> void:
    if puzzles.is_empty():
        return
    current_index = 0
    _show_puzzle()

func _show_puzzle() -> void:
    # Vertical-slice gameplay UI will be expanded in the next implementation step.
    var puzzle: Dictionary = puzzles[current_index]
    print("Puzzle %s: %s" % [puzzle.get("id", ""), puzzle.get("prompt", "")])
