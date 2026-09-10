from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
TRACKER = ROOT / "src" / "event_tracker.gd"
MAIN = ROOT / "src" / "main.gd"

EVENT_CONSTANTS = (
    "APP_STARTED",
    "LEVEL_STARTED",
    "ANSWER_SUBMITTED",
    "LEVEL_SOLVED",
    "LEVEL_FAILED",
    "HINT_USED",
    "LEVEL_SELECTED",
    "PROGRESS_RESET",
)


def test_tracker_records_and_exposes_provider_boundary():
    text = TRACKER.read_text(encoding="utf-8")
    assert "signal event_recorded(name: String, payload: Dictionary)" in text
    assert "event_recorded.emit(name, payload)" in text
    assert "func record(name: String, payload: Dictionary = {}) -> void:" in text
    assert "history.append(event)" in text
    assert "func drain() -> Array:" in text


def test_gameplay_uses_only_declared_event_constants():
    text = MAIN.read_text(encoding="utf-8")
    used = set(re.findall(r"EventTracker\.([A-Z_]+)", text))
    assert used
    assert used.issubset(set(EVENT_CONSTANTS)), sorted(used - set(EVENT_CONSTANTS))


def test_analytics_boundary_is_not_persisted_or_networked_by_tracker():
    text = TRACKER.read_text(encoding="utf-8").lower()
    forbidden = (
        "http://",
        "https://",
        "firebase",
        "amplitude",
        "mixpanel",
        "device_id",
        "ip_address",
    )
    assert not any(token in text for token in forbidden)


def test_tracker_keeps_disabled_mode_non_disruptive():
    text = TRACKER.read_text(encoding="utf-8")
    guard = re.search(
        r"func record\(name: String, payload: Dictionary = \{\}\) -> void:\n"
        r"\s+if not enabled or name\.strip_edges\(\)\.is_empty\(\):\n"
        r"\s+return",
        text,
    )
    assert guard, "disabled/invalid analytics events must be a no-op"
