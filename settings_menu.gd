extends Control

var GraphSetting = "Low"
@onready var LowLabel = $GrphLowButton/Label
@onready var HighLabel = $GrphHighButton/Label
@onready var Title = $Title
@onready var VolValue = $VolumeSlider/VolValue
@onready var RtrnLabel = $ReturnButton/RtrnLabel

func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
	print("returning to main menu")


func _ready() -> void:
	$VolValue.text = str(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))) # displays the audio value

	# title styling that can't be done with bbcode
	Title.add_theme_constant_override("outline_size", 10)
	Title.add_theme_color_override("font_outline_color", Color.BLACK)

	pass

func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	$VolValue.text = str(value)


func _on_grph_low_button_pressed() -> void:
	if GraphSetting != "Low":

		# insert graphics function here

		GraphSetting = "Low"
		LowLabel.text = "Low ✓" # the actual text displayed
		HighLabel.text = "High" # reset the other label
		print("Graphics set to Low")
	else:
		LowLabel.text = "Low ✓"
	pass # Replace with function body.


func _on_grph_high_button_pressed() -> void:

	# insert graphics function here

	if GraphSetting != "High":
		GraphSetting = "High"
		HighLabel.text = "High ✓" # the actual text displayed
		LowLabel.text = "Low" # reset the other label	
		print("Graphics set to High")
	else:
		HighLabel.text = "High"
	pass # Replace with function body.
