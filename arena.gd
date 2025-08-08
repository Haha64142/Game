extends Node3D

@export var arrow_scene: PackedScene
@export var orc_scene: PackedScene

@onready var player = $Player

func _ready() -> void:
	GameTime.start()
	$OrcSpawnTimer.timeout.emit()
	$OrcSpawnTimer.start()


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


func _on_player_player_dead() -> void:
	get_tree().call_group("Enemies", "queue_free")
	$OrcSpawnTimer.stop()
	
	$MouseTexture.player_dead = true
	Input.action_press("open_menu")
	await get_tree().create_timer(1).timeout
	Input.action_release("open_menu")
	
	var death_tween := $DeathScreen.create_tween()
	$DeathScreen.modulate.a = 0
	$DeathScreen.show()
	death_tween.tween_property($DeathScreen, "modulate:a", 0.7, 1)


func _on_orc_spawn_timer_timeout() -> void:
	var OrcNode: Area3D = orc_scene.duplicate().instantiate()
	var spawn_pos = Vector2.from_angle(randf_range(0.0, 2 * PI))
	spawn_pos *= randf_range(0.0, 9.0)
	OrcNode.position = Vector3(spawn_pos.x, 0.8, spawn_pos.y)
	add_child(OrcNode)
