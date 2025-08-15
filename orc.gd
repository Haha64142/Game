extends Enemy

## Player position offset time, in 1/100 second units (100 = 1.0s).
## The Orc goes to where the player was this amount of time ago
@export var chase_delay: int = 50

var hurt := false
var dead := false

var player: CharacterBody3D
var player_pos := Vector3.ZERO

var attacking := false
var player_hit_by_attack1 := false

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

@onready var attack1_hitboxes: Array[CollisionPolygon3D] = [
	$"Attack1-0",
	$"Attack1-1",
	$"Attack1-2",
	$"Attack1-3",
	$"Attack1-4",
	$"Attack1-5",
]

func _ready() -> void:
	initialize()
	add_to_group("Orcs")
	
	nav_agent.set_target_position(Global.player_pos)


func _physics_process(delta: float) -> void:
	if attacking or hurt or dead:
		return
	
	set_target_pos(player.prev_positions)
	player_pos = player.position
	
	if position.distance_to(player_pos) <= 0.5:
		$AnimatedSprite3D.play("attack1")
		attacking = true
		if player_pos.x >= position.x:
			scale.x = 1
		else:
			scale.x = -1
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


func set_target_pos(player_prev_pos: Dictionary[int, Vector3]) -> void:
	# Blue box
	var delayed_player_pos := find_closest_pos_to(player_prev_pos,
			int(GameTime.seconds * 100) - chase_delay)
	
	var player_distance := (player_pos - position).length() # Orc -> Red box
	var current_to_delayed_player_distance := (
			player_pos - delayed_player_pos
	).length() # Blue box -> Red box
	
	var target_pos: Vector3
	if player_distance < 2:
		target_pos = player_pos
	else:
		if !(player_distance < current_to_delayed_player_distance):
			target_pos = delayed_player_pos
		else:
			var temp_delay = 10 * player_distance
			target_pos = find_closest_pos_to(player_prev_pos,
					int(GameTime.seconds * 100) - temp_delay)
			
	
	# Red box
	$PlayerPos.position = player_pos
	$PlayerPos.visible = Global.display_debug_boxes
	
	# Blue box
	$DelayedPlayerPos.position = delayed_player_pos
	$DelayedPlayerPos.visible = Global.display_debug_boxes
	
	# Target box
	$Target.position = target_pos
	$Target.visible = Global.display_debug_boxes
	
	# Update player circles
	if Global.display_debug_circles:
		get_tree().call_group("Player", "update_circles",
			current_to_delayed_player_distance)
	
	nav_agent.set_target_position(target_pos)


func find_closest_pos_to(player_prev_pos: Dictionary[int, Vector3],
		target_time: int) -> Vector3:
	var keys: Array = player_prev_pos.keys()
	keys.sort()
	
	if keys.has(target_time):
		return player_prev_pos[target_time]
	
	for key in keys:
		if key >= target_time:
			return player_prev_pos[key]
	
	return player_prev_pos[keys.back()]


func _handle_hit(attack: Global.AttackType, node: Node3D) -> void:
	if hurt or dead:
		return
	if attacking:
		attack1_hitboxes[$AnimatedSprite3D.frame].set_deferred(
				"disabled", true
		)
		attacking = false
	match attack:
		Global.AttackType.Attack1:
			$AnimatedSprite3D.play("hurt")
			hurt = true
			health -= Global.player_damages[attack]
		
		Global.AttackType.Arrow:
			$AnimatedSprite3D.play("hurt")
			hurt = true
			var damage = Global.player_damages[attack] * node.power
			damage = max(damage, 10)
			health -= damage
	
	if hurt:
		await $AnimatedSprite3D.animation_finished
	if health <= 0:
		$AnimatedSprite3D.play("death")
		dead = true
		monitoring = false
		monitorable = false


func _hit_player() -> void:
	if player_hit_by_attack1:
		return
	
	player_hit_by_attack1 = true
	get_tree().call_group("Player", "_on_hit_by_enemy", self)


func _on_animated_sprite_3d_animation_finished() -> void:
	match $AnimatedSprite3D.animation:
		"hurt":
			hurt = false
			$AnimatedSprite3D.play("idle")
		"attack1":
			attacking = false
			player_hit_by_attack1 = false
			attack1_hitboxes[$AnimatedSprite3D.frame].disabled = true
			$AnimatedSprite3D.play("idle")


func _on_animated_sprite_3d_frame_changed() -> void:
	if $AnimatedSprite3D.animation != "attack1":
		return
	
	attack1_hitboxes[$AnimatedSprite3D.frame].disabled = false
	attack1_hitboxes[$AnimatedSprite3D.frame - 1].disabled = true
