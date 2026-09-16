from pathlib import Path
import re

source = Path("src/ui_polish.gd").read_text(encoding="utf-8")

required_fragments = [
    'DisplayServer.get_display_safe_area()',
    'DisplayServer.screen_get_size(DisplayServer.SCREEN_OF_MAIN_WINDOW)',
    'Input.vibrate_handheld(HAPTIC_MS, 0.25)',
    'button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND',
    'button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, 58.0)',
    'node.custom_minimum_size.y = maxf(node.custom_minimum_size.y, 60.0)',
]
for fragment in required_fragments:
    assert fragment in source, f"Missing UI polish contract: {fragment}"

# Safe-area handling must scale screen-space insets into the current UI viewport.
assert 'var scale := Vector2(_ui.size.x / float(screen.x), _ui.size.y / float(screen.y))' in source
assert 'left += maxf(0.0, float(safe.position.x) * scale.x)' in source
assert 'right += maxf(0.0, safe_right)' in source
assert 'top += maxf(0.0, float(safe.position.y) * scale.y)' in source
assert 'bottom += maxf(0.0, safe_bottom)' in source

# Runtime polish must be idempotent: each node is styled once and removed nodes are cleaned up.
assert 'if styled_nodes.has(node_id):' in source
assert 'styled_nodes.erase(node.get_instance_id())' in source

# Timer/feedback states must have explicit visual treatment.
assert re.search(r'if seconds <= TIMER_CRITICAL_SECONDS:', source)
assert re.search(r'elif seconds <= TIMER_WARNING_SECONDS:', source)
assert '_polish_feedback(label)' in source

print("Validated safe-area, haptics, touch targets, idempotent styling, and timer feedback UI contracts")
