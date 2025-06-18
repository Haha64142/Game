extends Node2D

var SCREEN_WIDTH: int = ProjectSettings.get_setting("display/window/size/viewport_width")
var SCREEN_HEIGHT: int = ProjectSettings.get_setting("display/window/size/viewport_height")
var _scale_factor := Vector2(1.0, 1.0)
var _offset := Vector2(0, 0)

var _window_mode: int = 0
var _window_modes = [
	DisplayServer.WINDOW_MODE_WINDOWED,
	DisplayServer.WINDOW_MODE_MAXIMIZED,
	#DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN,
]

var _mouse_sensitivity := 0.9

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	position = get_viewport().get_mouse_position()
	show()


func _process(_delta: float) -> void:
	_scale_factor = get_viewport_transform().get_scale()
	_offset = (Vector2(DisplayServer.window_get_size()) - get_viewport_rect().size * _scale_factor) / 2
	Global.mouse_pos = position
	if Input.is_action_just_pressed("open_menu"):
		if Global.mouse_visible:
			position = get_viewport().get_mouse_position()
			position.x = clamp(position.x, 0, SCREEN_WIDTH)
			position.y = clamp(position.y, 0, SCREEN_HEIGHT)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			show()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			Input.warp_mouse(position * _scale_factor + _offset)
			hide()
		Global.mouse_visible = !Global.mouse_visible
	
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("toggle_fullscreen"):
		if (_window_modes.has(DisplayServer.window_get_mode())):
			_window_mode = _window_modes.find(DisplayServer.window_get_mode())
		_window_mode += 1
		_window_mode %= _window_modes.size()
		DisplayServer.window_set_mode(_window_modes[_window_mode])


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Global.mouse_visible:
			position = get_viewport().get_mouse_position()
		else:
			position += event.screen_relative * _mouse_sensitivity / _scale_factor
			position.x = clamp(position.x, 0, SCREEN_WIDTH)
			position.y = clamp(position.y, 0, SCREEN_HEIGHT)
