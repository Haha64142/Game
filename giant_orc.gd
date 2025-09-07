extends Enemy

@export var axe_scene: PackedScene

var hurt := false
var dead := false

var attack := false
var stop_movement := false

var player: CharacterBody3D
var player_pos := Vector3.ZERO

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
	initialize()
	add_to_group("Orcs")
	
	nav_agent.set_target_position(Global.player_pos)
	$AxeTimer.start()


func _physics_process(delta: float) -> void:
	player_pos = player.position
	nav_agent.set_target_position(player_pos)
	
	if hurt or dead:
		return
	
	if attack:
		spawn_axe()
		return
	
	if $AxeTimer.time_left <= 1:
		$AnimatedSprite3D.pause()
		return
	
	if stop_movement:
		return
	
	if nav_agent.is_navigation_finished():
		$AnimatedSprite3D.play("idle")
		return
	
	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	
	var velocity = next_path_position - position
	if velocity.x >= 0:
		scale.x = 1
	else:
		scale.x = -1
	
	if velocity.length() > 0:
		$AnimatedSprite3D.play("run")
	else:
		$AnimatedSprite3D.play("idle")
	
	position = position.move_toward(next_path_position, delta * speed)


func spawn_axe() -> void:
	attack = false
	stop_movement = true
	$AnimatedSprite3D.play("attack1")
	
	var Axe: Area3D = axe_scene.instantiate()
	add_child(Axe)
	
	var distance := position.distance_to(player.position)
	var travel_time: float = distance / Axe.MOVE_SPEED
	
	var prev_pos: Vector3 = player.find_closest_pos_to(int(GameTime.seconds * 100) - 25)
	var player_velocity := (player.position - prev_pos) / 0.25
	
	var predicted := player.position + player_velocity * travel_time
	
	Axe.move_direction = position.direction_to(predicted)
	Axe.position = position + Vector3(0, 0.5, 0)
	
	Axe.check_flip_h()
	Axe.parent_orc = self
	$AxeTimer.start(randf_range(5.0, 10.0))


func _handle_hit(attack_type: Global.AttackType, node: Node3D) -> void:
	if hurt or dead:
		return
	var old_animation: StringName = $AnimatedSprite3D.animation
	match attack_type:
		Global.AttackType.Attack1:
			$AnimatedSprite3D.play("hurt")
			hurt = true
			health -= Global.player_damages[attack_type]
		
		Global.AttackType.Arrow:
			$AnimatedSprite3D.play("hurt")
			hurt = true
			var damage = Global.player_damages[attack_type] * node.power
			damage = max(damage, 10)
			health -= damage
	
	if hurt:
		$AxeTimer.paused = true
		await $AnimatedSprite3D.animation_finished
		hurt = false
		$AnimatedSprite3D.play(old_animation)
		$AxeTimer.paused = false
		if $AxeTimer.time_left < 2:
			$AxeTimer.start(2)
	if health <= 0:
		$AnimatedSprite3D.play("death")
		dead = true
		monitoring = false
		monitorable = false


func _hit_player() -> void:
	get_tree().call_group("Player", "_on_hit_by_enemy", self)


func _on_animated_sprite_3d_animation_finished() -> void:
	match $AnimatedSprite3D.animation:
		"attack1":
			$AnimatedSprite3D.play("regen_axe")
			await $AnimatedSprite3D.animation_finished
			stop_movement = false
			$AnimatedSprite3D.play("idle")


func _on_axe_timer_timeout() -> void:
	attack = true
