from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SRC_ROOT = PROJECT_ROOT / "src"


FORBIDDEN_NETWORK_APIS = (
    "HTTPRequest",
    "HTTPClient",
    "WebSocketPeer",
    "PacketPeer",
)


def _source_files():
    return sorted(SRC_ROOT.rglob("*.gd"))


def test_gameplay_sources_have_no_direct_network_dependencies():
    violations = []
    for path in _source_files():
        text = path.read_text(encoding="utf-8")
        for api in FORBIDDEN_NETWORK_APIS:
            if api in text:
                violations.append(f"{path.relative_to(PROJECT_ROOT)}: {api}")
    assert not violations, "Direct network dependency found: " + ", ".join(violations)


def test_gameplay_sources_contain_no_hardcoded_remote_urls():
    violations = []
    for path in _source_files():
        text = path.read_text(encoding="utf-8")
        for marker in ("https://", "http://"):
            if marker in text:
                violations.append(f"{path.relative_to(PROJECT_ROOT)}: {marker}")
    assert not violations, "Hardcoded remote URL found: " + ", ".join(violations)
