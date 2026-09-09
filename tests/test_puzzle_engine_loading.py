from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ENGINE = ROOT / "src" / "puzzle_engine.gd"


def test_failed_primary_catalog_load_clears_stale_engine_state():
    code = ENGINE.read_text(encoding="utf-8")
    load_body = code.split("func load_from_file(path: String) -> bool:", 1)[1].split("func _read_puzzles", 1)[0]
    assert "var incoming: Array = []" in load_body
    assert "if not _read_puzzles(path, incoming):" in load_body
    assert "        puzzles.clear()\n        return false" in load_body


def test_failed_extra_catalog_load_clears_stale_engine_state():
    code = ENGINE.read_text(encoding="utf-8")
    load_body = code.split("func load_from_file(path: String) -> bool:", 1)[1].split("func _read_puzzles", 1)[0]
    assert "if not _read_puzzles(extra_path, extra):" in load_body
    assert "            puzzles.clear()\n            return false" in load_body


def test_duplicate_id_failure_does_not_publish_partial_catalog():
    code = ENGINE.read_text(encoding="utf-8")
    load_body = code.split("func load_from_file(path: String) -> bool:", 1)[1].split("func _read_puzzles", 1)[0]
    assert 'last_error = "Invalid or duplicate puzzle id: " + id' in load_body
    assert "puzzles.clear()" in load_body
    assert "puzzles = incoming" in load_body
