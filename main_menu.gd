extends Control

func _ready() -> void:
	Global.mouse_visible = true


func _process(delta: float) -> void:
	if Input.is_action_pressed("exit"):
		get_tree().quit()


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://arena.tscn")
