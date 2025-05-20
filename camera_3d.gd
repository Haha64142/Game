extends Camera3D

var vector_diff := Vector2(0, 0)
var center := Vector2(ProjectSettings.get_setting("display/window/size/viewport_width") / 2, ProjectSettings.get_setting("display/window/size/viewport_height") / 2)

func _ready() -> void:
	position = Vector3(0, 6, 8)


func _process(_delta: float) -> void:
	vector_diff = Global.mouse_pos - center
	position = Vector3(vector_diff.x / 137.14, 6, vector_diff.y / 33.57)
