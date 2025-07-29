extends Node3D

@export var arrow_scene: PackedScene
@export var orc_scene: PackedScene

var OrcNode: Area3D

@onready var player = $Player

func _ready() -> void:
	GameTime.start()
	OrcNode = orc_scene.instantiate()
	$OrcSpawnTimer.timeout.emit()
	$OrcSpawnTimer.start()


func _process(_delta: float) -> void:
	var collision_keys: Array[String] = [
		"Floor",
		"Wall",
		"Player",
		"Attack1",
		"Arrow",
	]
	var _output := ""
	for i in collision_keys:
		if i != "Floor":
			_output += ", "
		_output += i + ": " + ("🟩" if $TestEnemy.collisions[i] else "🟥")
	
	#print(_output)


func _physics_process(delta: float) -> void:
	get_tree().call_group("Orcs", "set_target_pos", player.prev_positions)
	get_tree().set_group("Orcs", "player_pos", player.position)


func _on_player_arrow_fired(shot_power: float,
		mouse_pos: Vector2, player_pos: Vector3) -> void:
	var Arrow: Area3D = arrow_scene.instantiate()
	add_child(Arrow)
	Arrow.shoot(shot_power, mouse_pos, player_pos)


func _on_player_attack_1_finished() -> void:
	get_tree().call_group("Enemies", "attack1_finished")


func _on_orc_spawn_timer_timeout() -> void:
	var Orc: Area3D = OrcNode.duplicate()
	var spawn_pos = Vector2.from_angle(randf_range(0.0, 2 * PI))
	spawn_pos *= randf_range(0.0, 9.0)
	Orc.position = Vector3(spawn_pos.x,
			OrcNode.position.y, spawn_pos.y)
	add_child(Orc)
