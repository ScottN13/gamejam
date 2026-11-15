extends Range # Works for both ProgressBar and TextureProgressBar

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
	max_value = max_health
	current_health = max_health
	value = current_health

func take_damage(amount: int) -> void:
	current_health = clamp(current_health - amount, 0, max_health)
	value = current_health

# Temporary test: Press the Spacebar (ui_accept) to test if the bar drops
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		take_damage(10)s
