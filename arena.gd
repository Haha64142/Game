extends Node3D

@export var arrow_scene : PackedScene
 
func shoot_arrow(shot_power: float, mouse_pos: Vector2, player_pos: Vector3):
	var arrow : Node = arrow_scene.instantiate()
	add_child(arrow)
	arrow.shoot(shot_power, mouse_pos, player_pos)


func _on_player_attack_1_finished() -> void:
	$Enemy.attack1_finished()
