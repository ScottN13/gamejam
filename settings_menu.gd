extends Control


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
	print("returning to main menu")
