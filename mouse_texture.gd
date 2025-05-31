extends Node2D

var SCREEN_WIDTH : int = ProjectSettings.get_setting("display/window/size/viewport_width")
var SCREEN_HEIGHT : int = ProjectSettings.get_setting("display/window/size/viewport_height")
var scale_factor : Vector2 = Vector2(1.0, 1.0)

var mouse_sensitivity := 0.9
@onready var crosshair := $Crosshair

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	position = get_viewport().get_mouse_position()
	show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	Global.mouse_pos = position
	if Input.is_action_just_pressed("ui_cancel"):
		if Global.mouse_visible:
			position = get_viewport().get_mouse_position()
			position.x = clamp(position.x, 0, SCREEN_WIDTH)
			position.y = clamp(position.y, 0, SCREEN_HEIGHT)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			show()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			scale_factor = get_viewport_transform().get_scale()
			Input.warp_mouse(Vector2(position.x * scale_factor.x, position.y * scale_factor.y))
			hide()
		Global.mouse_visible = !Global.mouse_visible
	
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Global.mouse_visible:
			position = get_viewport().get_mouse_position()
		else:
			position += event.screen_relative * mouse_sensitivity
			position.x = clamp(position.x, 0, SCREEN_WIDTH)
			position.y = clamp(position.y, 0, SCREEN_HEIGHT)
