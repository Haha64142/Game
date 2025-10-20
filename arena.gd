extends Node3D

@export var orc_scene: PackedScene
@export var giant_orc_scene: PackedScene

@onready var player: CharacterBody3D = $Player
@onready var nav_map_rid: RID = $NavigationRegion3D.get_navigation_map()

func _ready() -> void:
	GameTime.start()
	$OrcSpawnTimer.start()
	Global.mouse_visible = false
	$MouseTexture.hide_mouse()
	Global.can_pause = true


func _on_player_player_dead() -> void:
	get_tree().call_group("Enemies", "queue_free")
	$OrcSpawnTimer.stop()
	Global.can_pause = false
	
	$MouseTexture.show_mouse(false)
	$DeathScreen.show_death_screen()


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
	if paused:
		$MouseTexture.show_mouse(false)
		$Player/Camera3D.reset_pos()
	else:
		$MouseTexture.hide_mouse()
