extends Control

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		_on_back_button_pressed()


func _on_back_button_pressed() -> void:
	queue_free()
