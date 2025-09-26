extends Node

@export var display_debug_boxes = false
@export var display_debug_circles = false

enum AttackType {
	None,
	Attack1,
	Arrow,
}

var window_mode: int = 0
var window_modes: Array[DisplayServer.WindowMode] = [
	DisplayServer.WINDOW_MODE_WINDOWED,
	DisplayServer.WINDOW_MODE_MAXIMIZED,
	#DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN,
]

var use_global_shortcuts := true

var mouse_pos := Vector2.ZERO
var respawn_pos := Vector3(0, 1, 0)
var mouse_visible := false
var player_pos := Vector3.ZERO

var player_damages: Dictionary[AttackType, int]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if use_global_shortcuts:
		if Input.is_action_pressed("exit"):
			get_tree().quit()
		
		if Input.is_action_just_pressed("toggle_fullscreen"):
			if (window_modes.has(DisplayServer.window_get_mode())):
				window_mode = window_modes.find(DisplayServer.window_get_mode())
			window_mode += 1
			window_mode %= window_modes.size()
			DisplayServer.window_set_mode(window_modes[window_mode])
