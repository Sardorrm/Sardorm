from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
TRACKER = ROOT / "src" / "event_tracker.gd"
CONTRACT = ROOT / "docs" / "ANALYTICS_EVENT_CONTRACT.md"
PRIVACY_REVIEW = ROOT / "docs" / "PRIVACY_DATA_REVIEW.md"

FORBIDDEN_TELEMETRY_FIELDS = (
    "name",
    "email",
    "device identifier",
    "device_id",
    "ip address",
    "precise location",
    "free-form user text",
    "answer text",
)


def test_privacy_review_exists_and_is_explicit():
    text = PRIVACY_REVIEW.read_text(encoding="utf-8")
    assert "privacy-safe by default" in text
    assert "provider" in text.lower()


def test_event_contract_excludes_personal_data_fields():
    text = CONTRACT.read_text(encoding="utf-8").lower()
    for field in FORBIDDEN_TELEMETRY_FIELDS:
        assert field in text


def test_tracker_has_no_network_or_persistence_api():
    text = TRACKER.read_text(encoding="utf-8").lower()
    forbidden = ("http://", "https://", "httprequest", "httpclient", "fileaccess", "configfile")
    assert not any(token in text for token in forbidden)


def test_tracker_payload_is_gameplay_event_data_only():
    text = TRACKER.read_text(encoding="utf-8")
    assert '"payload": payload.duplicate(true)' in text
    assert re.search(r"signal\s+event_recorded\(name:\s*String,\s*payload:\s*Dictionary\)", text)
