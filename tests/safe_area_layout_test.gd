extends SceneTree

const UiPolish = preload("res://src/ui_polish.gd")

func _init() -> void:
    var helper := UiPolish.new()
    _assert_margins(helper.calculate_safe_margins(Vector2(1080, 1920), Vector2(1080, 1920), Rect2(0, 80, 1080, 1760), true), Vector4(24, 24, 108, 188))
    _assert_margins(helper.calculate_safe_margins(Vector2(540, 960), Vector2(1080, 1920), Rect2(0, 80, 1080, 1760), true), Vector4(24, 24, 64, 108))
    _assert_margins(helper.calculate_safe_margins(Vector2(1080, 1920), Vector2(1080, 1920), Rect2(0, 0, 1080, 1920), true), Vector4(24, 24, 28, 28))
    _assert_margins(helper.calculate_safe_margins(Vector2(1080, 1920), Vector2(1080, 1920), Rect2(0, 80, 1080, 1760), false), Vector4(24, 24, 28, 28))
    _assert_margins(helper.calculate_safe_margins(Vector2.ZERO, Vector2.ZERO, Rect2(), true), Vector4(24, 24, 28, 28))
    print("Safe-area portrait contract tests passed")
    quit(0)

func _assert_margins(actual: Vector4, expected: Vector4) -> void:
    assert(is_equal_approx(actual.x, expected.x), "left margin mismatch: %s" % actual)
    assert(is_equal_approx(actual.y, expected.y), "right margin mismatch: %s" % actual)
    assert(is_equal_approx(actual.z, expected.z), "top margin mismatch: %s" % actual)
    assert(is_equal_approx(actual.w, expected.w), "bottom margin mismatch: %s" % actual)
