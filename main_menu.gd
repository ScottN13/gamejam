extends Control

@onready var StartLabel = $StartButton/StartLabel
@onready var SettingsLabel = $SettingsButton/SettingsLabel
@onready var CloseLabel = $CloseButton/CloseLabel
@onready var Title = $Title

func _ready() -> void:
	Title.add_theme_constant_override("outline_size", 10)
	Title.add_theme_color_override("font_outline_color", Color.BLACK)

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")
	print("game started!")


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://settings_menu.tscn")
	print("changed to settings")


func _on_close_button_pressed() -> void:
	get_tree().quit()
