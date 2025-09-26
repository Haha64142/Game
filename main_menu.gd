extends Control

var settings_screen := preload("res://settings_screen.tscn")
var SettingsNode: Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.mouse_visible = true


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://arena.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	SettingsNode = settings_screen.instantiate()
	add_child(SettingsNode)
