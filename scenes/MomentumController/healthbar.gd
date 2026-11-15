## health_bar.gd
## Godot 4.x
## Attach this script to a TextureProgressBar node.
##
## Textures used (from Pixel Bar Starter Pack):
##   texture_over     -> 1-Hearth_Bar_Outline.png (64x16, heart icon + empty segments)
##   texture_progress -> 1-Hearth_Bar_Fill.png    (64x16, red segments)
extends TextureProgressBar
class_name HealthBar

signal health_changed(current: float, maximum: float)
signal died

@export var max_health: float = 100.0
@export var animate: bool = true
@export var animation_time: float = 0.25

# The fill sprite is 64px wide, but its colored segments only occupy
# x = 14 .. 53 (40px). We map health onto that visible range so that
# 0% health really looks empty and 100% really looks full.
const CANVAS_WIDTH := 64.0
const FILL_START := 14.0
const FILL_WIDTH := 40.0

var health: float = 0.0
var _tween: Tween


func _ready() -> void:
	# The bar works in pixel units of the texture, not in health units.
	min_value = 0.0
	max_value = CANVAS_WIDTH
	health = max_health
	_show_ratio(1.0, false)


func set_health(new_health: float) -> void:
	var previous := health
	health = clampf(new_health, 0.0, max_health)

	if health != previous:
		health_changed.emit(health, max_health)

	_show_ratio(health / max_health, animate)

	if previous > 0.0 and health <= 0.0:
		died.emit()


func take_damage(amount: float) -> void:
	set_health(health - amount)


func heal(amount: float) -> void:
	set_health(health + amount)


func is_dead() -> bool:
	return health <= 0.0


func _show_ratio(ratio: float, use_tween: bool) -> void:
	var target := FILL_START + FILL_WIDTH * ratio

	if _tween and _tween.is_valid():
		_tween.kill()

	if use_tween:
		_tween = create_tween()
		_tween.tween_property(self, "value", target, animation_time)
	else:
		value = target
