extends Node2D

var SCREEN_WIDTH: int = ProjectSettings.get_setting(
		"display/window/size/viewport_width")
var SCREEN_HEIGHT: int = ProjectSettings.get_setting(
		"display/window/size/viewport_height")
var scale_factor := Vector2(1.0, 1.0)
var offset := Vector2(0, 0)

var player_dead = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	position = get_viewport().get_mouse_position()
	show()


func _process(_delta: float) -> void:
	scale_factor = get_viewport_transform().get_scale()
	offset = (Vector2(DisplayServer.window_get_size())
			- get_viewport_rect().size * scale_factor) / 2
	Global.mouse_pos = position


func toggle_mouse() -> void:
	if not player_dead:
		if Global.mouse_visible:
			hide_mouse()
		else:
			show_mouse(false)
	else:
		show_mouse(true)


func show_mouse(center: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if not center:
		Input.warp_mouse(position * scale_factor + offset)
	hide()
	Global.mouse_visible = true


func hide_mouse() -> void:
	position = get_viewport().get_mouse_position()
	position.x = clamp(position.x, 0, SCREEN_WIDTH)
	position.y = clamp(position.y, 0, SCREEN_HEIGHT)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	show()
	Global.mouse_visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Global.mouse_visible:
			position = get_viewport().get_mouse_position()
		else:
			position += (event.screen_relative
					* Settings.mouse_sensitivity / scale_factor)
			position.x = clamp(position.x, 0, SCREEN_WIDTH)
			position.y = clamp(position.y, 0, SCREEN_HEIGHT)
