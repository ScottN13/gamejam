extends Control

const SAVE_PATH = "user://save_data.json"

@onready var dataDisplay = $data_display
@onready var anim: AnimatedSprite2D = $Node2D/CharacterBody2D/AnimatedSprite2D

var levels_completed: int = 0
var total_stars: int = 0
var total_deaths: int = 0


@export var speed: float = 300.0
@export var acceleration: float = 2000.0
@export var friction: float = 2500.0
@export var jump_velocity: float = -450.0
@export var velocity: Vector2 = Vector2.ZERO


func save_game() -> void:
	var data := {
		"total_deaths": total_deaths,
		"total_stars": total_stars,
		"levels_completed": levels_completed,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not open save file: %s" % FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(data, "\t"))

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return  # first launch: keep defaults
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return  # corrupted file: keep defaults
	 
	total_deaths = int(parsed.get("total_deaths", 0))
	total_stars = int(parsed.get("total_stars", 0))
	levels_completed = int(parsed.get("levels_completed", 0))

func get_debug_text() -> String:
	return "Deaths: %d\nStars: %d\nLevels completed: %d" % [
		total_deaths, total_stars, levels_completed
	]

# Shows what's actually on disk, which can differ from what's in memory
func get_saved_file_text() -> String:
	if not FileAccess.file_exists(SAVE_PATH):
		return "(no save file yet)"
	return FileAccess.get_file_as_string(SAVE_PATH)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		load_game()
	else:
		save_game()  # creates the file with default values
	print("debug menu ready")
	print("reading save data")
	load_game()
	dataDisplay.text = get_debug_text() + "\n\n" + get_saved_file_text()




func _on_give_level_completed_pressed() -> void:
	levels_completed += 1
	save_game()


func _on_give_death_pressed() -> void:
	total_deaths += 1
	save_game()


func _on_give_star_pressed() -> void:
	total_stars += 1
	save_game()


func _on_readsave_pressed() -> void:
	load_game()
	dataDisplay.text = get_debug_text() + "\n\n" + get_saved_file_text()

func _on_resetsave_pressed() -> void:
	total_deaths = 0
	total_stars = 0
	levels_completed = 0
	save_game()



# Movement


