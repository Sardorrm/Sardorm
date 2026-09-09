from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_ui_polish_avoids_per_frame_recursive_tree_scan():
    code = (ROOT / "src" / "ui_polish.gd").read_text(encoding="utf-8")
    process = code.split("func _process(delta: float) -> void:", 1)[1].split("func _on_node_added", 1)[0]
    assert "_polish_tree(" not in process
    assert "_polish_tree_once(" not in process
    assert "node_added.connect(_on_node_added)" in code
    assert "node_removed.connect(_on_node_removed)" in code


def test_ui_polish_refreshes_safe_area_only_when_layout_changes():
    code = (ROOT / "src" / "ui_polish.gd").read_text(encoding="utf-8")
    assert "_last_ui_size" in code
    assert "_last_screen_size" in code
    assert "_refresh_safe_area_if_needed(root)" in code
    assert "if not force and ui.size == _last_ui_size and screen == _last_screen_size:" in code


def test_ui_polish_tracks_dynamic_timer_without_hardcoded_scene_path():
    code = (ROOT / "src" / "ui_polish.gd").read_text(encoding="utf-8")
    assert "var active_timer_label: Label" in code
    assert "active_timer_label = label" in code
    assert 'get_node_or_null("Control/MarginContainer/VBoxContainer/Label")' not in code
    assert "get_tree().node_removed.connect(_on_node_removed)" in code
    assert "if node == active_timer_label:" in code


def test_ui_polish_keeps_timer_animation_and_static_button_polish():
    code = (ROOT / "src" / "ui_polish.gd").read_text(encoding="utf-8")
    assert "if is_instance_valid(active_timer_label)" in code
    assert "_polish_timer(active_timer_label)" in code
    assert "_apply_static_polish(node)" in code
    assert "button.pressed.is_connected(_on_button_pressed)" in code


def test_ui_polish_removed_nodes_are_evicted_from_tracking_cache():
    code = (ROOT / "src" / "ui_polish.gd").read_text(encoding="utf-8")
    assert "func _on_node_removed(node: Node) -> void:" in code
    assert "styled_nodes.erase(node.get_instance_id())" in code
    assert "active_timer_label = null" in code
