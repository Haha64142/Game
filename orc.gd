extends Enemy

## Player position offset time, in 1/100 second units (100 = 1.0s).
## The Orc goes to where the player was this amount of time ago
@export var chase_delay: int = 50

var hurt := false
var dead := false

var player_pos := Vector3.ZERO
var attacking := false
var _player_hit_by_attack1 := false

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

@onready var _attack1_hitboxes: Array[CollisionPolygon3D] = [
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
	var target_pos = find_closest_pos_to(player_prev_pos,
			int(GameTime.seconds * 100) - chase_delay)
	
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
		_attack1_hitboxes[$AnimatedSprite3D.frame].set_deferred(
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
	if _player_hit_by_attack1:
		return
	
	_player_hit_by_attack1 = true
	get_tree().call_group("Player", "_on_hit_by_enemy", self)


func _on_animated_sprite_3d_animation_finished() -> void:
	match $AnimatedSprite3D.animation:
		"hurt":
			hurt = false
			$AnimatedSprite3D.play("idle")
		"attack1":
			attacking = false
			_player_hit_by_attack1 = false
			_attack1_hitboxes[$AnimatedSprite3D.frame].disabled = true
			$AnimatedSprite3D.play("idle")


func _on_animated_sprite_3d_frame_changed() -> void:
	if $AnimatedSprite3D.animation != "attack1":
		return
	
	_attack1_hitboxes[$AnimatedSprite3D.frame].disabled = false
	_attack1_hitboxes[$AnimatedSprite3D.frame - 1].disabled = true
