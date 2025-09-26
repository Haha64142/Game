extends Camera3D

var start_pos := Vector3(0, 7, 7)
var vector_diff: Vector2
var center := Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width") / 2,
		ProjectSettings.get_setting("display/window/size/viewport_height") / 2)

func _ready() -> void:
	reset_pos()


func _process(_delta: float) -> void:
	if not Global.mouse_visible:
		vector_diff = Global.mouse_pos - center
		position = Vector3(
				vector_diff.x / 153 + start_pos.x,
				start_pos.y,
				vector_diff.y / 110 + start_pos.z
		)
	else:
		reset_pos()


func reset_pos() -> void:
	position = start_pos
