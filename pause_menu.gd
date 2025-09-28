extends Control

signal paused_changed(paused: bool)

var settings_screen := preload("res://settings_screen.tscn")
var ChildScreen: Control

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			if not is_instance_valid(ChildScreen):
				resume()
		else:
			if Global.can_pause:
				pause()


func pause() -> void:
	get_tree().paused = true
	show()
	paused_changed.emit(true)


func resume() -> void:
	hide()
	get_tree().paused = false
	paused_changed.emit(false)


func _on_resume_button_pressed() -> void:
	resume()


func _on_settings_button_pressed() -> void:
	ChildScreen = settings_screen.instantiate()
	add_child(ChildScreen)


func _on_exit_button_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://main_menu.tscn")
