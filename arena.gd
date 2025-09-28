extends Node3D

@export var arrow_scene: PackedScene
@export var orc_scene: PackedScene
@export var giant_orc_scene: PackedScene

var player_dead := false

@onready var player: CharacterBody3D = $Player
@onready var nav_map_rid: RID = $NavigationRegion3D.get_navigation_map()

func _ready() -> void:
	GameTime.start()
	$OrcSpawnTimer.start()
	Global.mouse_visible = false


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and not player_dead:
		get_tree().paused = true
		$MouseTexture.show_mouse(false)
		$Player/Camera3D.reset_pos()
		$PauseMenu.show()


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
	
	player_dead = true
	$MouseTexture.player_dead = true
	$MouseTexture.show_mouse(false)
	
	var death_tween := $DeathScreen.create_tween()
	$DeathScreen.modulate.a = 0
	$DeathScreen.show()
	death_tween.tween_property($DeathScreen, "modulate:a", 0.7, 1)


func _on_orc_spawn_timer_timeout() -> void:
	var NewEnemy: Enemy
	if randi() % 2 == 0:
		NewEnemy = giant_orc_scene.duplicate().instantiate()
	else:
		NewEnemy = orc_scene.duplicate().instantiate()
	
	var spawn_pos := NavigationServer3D.map_get_random_point(
			nav_map_rid,
			1,
			true
	)
	NewEnemy.player = player
	add_child(NewEnemy)
	NewEnemy.global_position = Vector3(spawn_pos.x, 0.8, spawn_pos.y)


func _on_pause_menu_paused_changed(paused: bool) -> void:
	if not paused:
		$MouseTexture.hide_mouse()
