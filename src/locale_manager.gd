class_name LocaleManager
extends RefCounted

const EN = "en"
const UZ = "uz"
const RU = "ru"
const LANGUAGES = [UZ, RU, EN]

static func supported_languages():
    return LANGUAGES.duplicate()

static func normalize(value: String) -> String:
    var code = value.to_lower().strip_edges()
    if LANGUAGES.has(code):
        return code
    return UZ
