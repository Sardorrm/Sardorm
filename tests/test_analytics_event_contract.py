from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
TRACKER = ROOT / "src" / "event_tracker.gd"
MAIN = ROOT / "src" / "main.gd"

EXPECTED_EVENTS = {
    "APP_STARTED": "app_started",
    "LEVEL_STARTED": "level_started",
    "ANSWER_SUBMITTED": "answer_submitted",
    "LEVEL_SOLVED": "level_solved",
    "LEVEL_FAILED": "level_failed",
    "HINT_USED": "hint_used",
    "LEVEL_SELECTED": "level_selected",
    "PROGRESS_RESET": "progress_reset",
}


def test_event_names_are_stable_snake_case_and_unique():
    text = TRACKER.read_text(encoding="utf-8")
    values = []
    for constant, expected in EXPECTED_EVENTS.items():
        match = re.search(rf'const\s+{constant}\s*:=\s*"([a-z0-9_]+)"', text)
        assert match, f"missing EventTracker.{constant}"
        assert match.group(1) == expected
        values.append(match.group(1))
    assert len(values) == len(set(values))


def test_gameplay_does_not_record_raw_answer_text():
    text = MAIN.read_text(encoding="utf-8")
    event_block = re.search(
        r'events\.record\(EventTracker\.ANSWER_SUBMITTED,\s*\{(?P<body>.*?)\}\)',
        text,
        re.DOTALL,
    )
    assert event_block, "answer_submitted event contract is not wired"
    body = event_block.group("body")
    assert '"puzzle_id"' in body
    assert '"correct"' in body
    assert '"attempt"' in body
    assert '"daily"' in body
    assert 'value' not in body
    assert 'answer' not in body.lower()


def test_tracker_has_no_vendor_sdk_or_network_dependency():
    text = TRACKER.read_text(encoding="utf-8").lower()
    forbidden = ("firebase", "amplitude", "mixpanel", "http://", "https://")
    assert not any(token in text for token in forbidden)
