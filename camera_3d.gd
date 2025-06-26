extends Camera3D

var _vector_diff := Vector2(0, 0)
var _center := Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width") / 2,
		ProjectSettings.get_setting("display/window/size/viewport_height") / 2)

func _ready() -> void:
	position = Vector3(0, 7, 7)


func _process(_delta: float) -> void:
	if not Global.mouse_visible:
		_vector_diff = Global.mouse_pos - _center
		position = Vector3(_vector_diff.x / 153, 7, _vector_diff.y / 110 + 7)
	else:
		position = Vector3(0, 7, 7)
