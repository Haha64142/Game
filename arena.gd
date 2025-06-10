extends Node3D

@export var arrow_scene : PackedScene

@onready var camera = $Player/Camera3D  # Adjust if nested
func shoot_arrow(mouse_pos: Vector2, player_pos: Vector3):
	var arrow = arrow_scene.instantiate()
	add_child(arrow)
	arrow.shoot(mouse_pos)
	arrow.position = player_pos
