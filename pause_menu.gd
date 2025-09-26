extends Control

signal paused_changed(paused: bool)

var settings_screen := preload("res://settings_screen.tscn")
var SettingsNode: Control
var pause_released := false
var in_secondary_menu := false

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("pause") and pause_released
			and not in_secondary_menu):
		resume()
	if not Input.is_action_pressed("pause"):
		pause_released = true


func resume() -> void:
	pause_released = false
	hide()
	get_tree().paused = false
	paused_changed.emit(false)


func _on_resume_button_pressed() -> void:
	resume()


func _on_settings_button_pressed() -> void:
	SettingsNode = settings_screen.instantiate()
	add_child(SettingsNode)
	in_secondary_menu = true


func _on_exit_button_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_child_exiting_tree(node: Node) -> void:
	if node == SettingsNode:
		in_secondary_menu = false
