from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
LISTING = ROOT / "docs" / "STORE_LISTING.md"


def test_store_listing_contains_required_sections_and_drafts():
    text = LISTING.read_text(encoding="utf-8")
    assert "## Store listing copy" in text
    assert "### Short description (draft)" in text
    assert "### Full description (draft)" in text
    assert "## Screenshot set" in text
    assert "## Listing decisions still requiring owner/release-account input" in text


def test_short_description_is_within_google_play_limit():
    text = LISTING.read_text(encoding="utf-8")
    match = re.search(
        r"### Short description \(draft\)\n\n([^\n]+)", text
    )
    assert match, "short description draft is missing"
    assert len(match.group(1)) <= 80


def test_screenshot_plan_covers_four_required_states():
    text = LISTING.read_text(encoding="utf-8")
    for state in ("**Home**", "**Puzzle**", "**Result**", "**Daily Challenge**"):
        assert state in text


def test_listing_avoids_unverified_service_claims():
    text = LISTING.read_text(encoding="utf-8").lower()
    assert "intentionally avoids claims about online services, ads, purchases, or telemetry" in text
