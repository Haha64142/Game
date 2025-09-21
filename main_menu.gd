extends Control

func _ready() -> void:
	Global.mouse_visible = true


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://arena.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
