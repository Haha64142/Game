extends Control

func show_death_screen() -> void:
	var death_tween := create_tween()
	modulate.a = 0
	show()
	death_tween.tween_property(self, "modulate:a", 0.7, 1)


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
