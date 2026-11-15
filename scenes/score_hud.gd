extends Label

func _ready() -> void:
	# Set the initial text when the level loads
	text = "Score: " + str(Global.score)
	# Listen for future score updates
	Global.score_updated.connect(_on_score_updated)

func _on_score_updated(new_score: int) -> void:
	text = "Score: " + str(new_score)
