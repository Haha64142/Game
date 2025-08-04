extends Node

@export var display_debug_boxes = false
@export var display_debug_circles = false

enum AttackType {
	None,
	Attack1,
	Arrow,
}

var mouse_pos := Vector2.ZERO
var respawn_pos := Vector3(0, 3, 0)
var mouse_visible := false
var player_pos := Vector3.ZERO

var player_damages: Dictionary[AttackType, int]
