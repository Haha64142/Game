extends Node3D

@export var arrow_scene: PackedScene

func _process(_delta: float) -> void:
	var collision_keys := ["Floor", "Wall", "Player", "Attack1", "Arrow"]
	var _output := ""
	for i in collision_keys:
		if i != "Floor":
			_output += ", "
		_output += i + ": " + ("🟩" if $TestEnemy.collisions[i] else "🟥")
	
	#print(_output)


func _on_player_arrow_fired(shot_power: float, mouse_pos: Vector2, player_pos: Vector3):
	var Arrow: Area3D = arrow_scene.instantiate()
	add_child(Arrow)
	Arrow.shoot(shot_power, mouse_pos, player_pos)


func _on_player_attack_1_finished() -> void:
	get_tree().call_group("Enemies", "attack1_finished")
