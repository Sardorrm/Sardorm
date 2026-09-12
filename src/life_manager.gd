class_name LifeManager
extends RefCounted

const MAX_LIVES: int = 3
const RECOVERY_SECONDS: int = 300

var lives: int = MAX_LIVES
var last_loss_unix: int = 0

func load_from_dict(data: Dictionary) -> void:
    lives = clampi(int(data.get("lives", MAX_LIVES)), 0, MAX_LIVES)
    last_loss_unix = maxi(0, int(data.get("last_loss_unix", 0)))
    recover()

func lose_life(now: int = -1) -> bool:
    recover(now)
    if lives <= 0:
        return false
    lives -= 1
    last_loss_unix = int(Time.get_unix_time_from_system()) if now < 0 else now
    return true

func add_life(amount: int = 1) -> void:
    lives = mini(MAX_LIVES, lives + maxi(0, amount))
    if lives == MAX_LIVES:
        last_loss_unix = 0

func recover(now: int = -1) -> void:
    if lives >= MAX_LIVES or last_loss_unix <= 0:
        return
    var current: int = int(Time.get_unix_time_from_system()) if now < 0 else now
    var recovered: int = int((current - last_loss_unix) / RECOVERY_SECONDS)
    if recovered <= 0:
        return
    lives = mini(MAX_LIVES, lives + recovered)
    if lives >= MAX_LIVES:
        last_loss_unix = 0
    else:
        last_loss_unix += recovered * RECOVERY_SECONDS

func seconds_to_next_life(now: int = -1) -> int:
    recover(now)
    if lives >= MAX_LIVES or last_loss_unix <= 0:
        return 0
    var current: int = int(Time.get_unix_time_from_system()) if now < 0 else now
    return maxi(0, RECOVERY_SECONDS - (current - last_loss_unix))

func is_empty() -> bool:
    recover()
    return lives <= 0

func to_dict() -> Dictionary:
    return {"lives": lives, "last_loss_unix": last_loss_unix}
