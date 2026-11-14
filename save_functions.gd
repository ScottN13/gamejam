extends Control

const SAVE_PATH = "user://save_data.json" # MUST ALWAYS BE PREZENT

#default values, always initialize at the begining
var levels_completed: int = 0
var total_stars: int = 0
var total_deaths: int = 0


func save_game() -> void:
	var data := {
		"total_deaths": total_deaths, # set values
		"total_stars": total_stars,
		"levels_completed": levels_completed,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE) # write to the file, if it doesn't exist it will be created
	if file == null:
		push_error("Could not open save file: %s" % FileAccess.get_open_error()) # fallback error
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
	 
	#total_deaths = int(parsed.get("total_deaths", 0))
	#total_stars = int(parsed.get("total_stars", 0))
	#levels_completed = int(parsed.get("levels_completed", 0))


func get_save_value(key: String, default: Variant) -> Variant:
	if not FileAccess.file_exists(SAVE_PATH):
		return default
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return default
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return default  # corrupted file: keep defaults
	return parsed.get(key, default)

# Called when the node enters the scene tree for the first time.
func check_save_file() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		load_game()
	else:
		save_game()  # creates the file with default values

# Shows what's actually on disk, which can differ from what's in memory
func get_saved_file_text() -> String:
	return "Deaths: %d\nStars: %d\nLevels completed: %d" % [
	    total_deaths, total_stars, levels_completed
	]


# cum se salveaza date:
# trebuie sa initiezi variabilele inainte de a le salva, altfel se salveaza doar default values (adica 0)
# apoi la fiecare modificare a variabilelor trebuie sa modifici valoarea si apoi apelezi save_game() ca sa se salveze in fisier
# va arata ceva de genul:
#####################
#
#   total_deaths +=1
#   save_game()
#
#####################

#restul va descarcati voi
#va pup din somnul meu