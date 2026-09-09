from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_lifecycle_does_not_poll_scene_tree_each_frame():
    code = (ROOT / "src" / "app_lifecycle.gd").read_text(encoding="utf-8")
    assert "func _process(" not in code
    assert "func _physics_process(" not in code
    assert "NOTIFICATION_APPLICATION_PAUSED" in code
    assert "NOTIFICATION_APPLICATION_RESUMED" in code


def test_ui_polish_uses_lifecycle_signals_for_dynamic_nodes():
    code = (ROOT / "src" / "ui_polish.gd").read_text(encoding="utf-8")
    assert "get_tree().node_added.connect(_on_node_added)" in code
    assert "get_tree().node_removed.connect(_on_node_removed)" in code
    assert "styled_nodes.erase(node.get_instance_id())" in code


def test_ui_polish_only_keeps_timer_animation_in_per_frame_path():
    code = (ROOT / "src" / "ui_polish.gd").read_text(encoding="utf-8")
    process = code.split("func _process(delta: float) -> void:", 1)[1].split("func _on_node_added", 1)[0]
    assert "_polish_tree_once" not in process
    assert "get_children()" not in process
    assert "get_node_or_null(" not in process
    assert "_polish_timer(active_timer_label)" in process
