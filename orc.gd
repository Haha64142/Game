extends Enemy

## Player position offset time, in 1/10 second units (10 = 1.0s).
## The Orc goes to where the player was this amount of time ago
@export var chase_delay: int = 5

var hurt := false

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
	initialize()
	add_to_group("Orcs")
	
	nav_agent.set_target_position(Global.player_pos)


func _physics_process(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return
	
	if hurt:
		return
	
	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	
	var velocity = next_path_position - position
	if velocity.x >= 0:
		$AnimatedSprite3D.flip_h = false
	else:
		$AnimatedSprite3D.flip_h = true
	
	if velocity.length() > 0:
		$AnimatedSprite3D.play("run")
	else:
		$AnimatedSprite3D.play("idle")
	
	position = position.move_toward(next_path_position, delta * speed)


func set_target_pos(player_prev_pos: Dictionary[int, Vector3]) -> void:
	var target_pos = find_closest_pos_to(player_prev_pos,
			int(GameTime.seconds * 10) - chase_delay)
	
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


func _handle_hit(attack: AttackType, node: Node3D) -> void:
	match attack:
		AttackType.Attack1:
			print("Hit by Attack1")
			$AnimatedSprite3D.play("hurt")
			hurt = true
		
		AttackType.Arrow:
			print("Hit by Arrow")
			$AnimatedSprite3D.play("hurt")
			hurt = true


func _on_animated_sprite_3d_animation_finished() -> void:
	match $AnimatedSprite3D.animation:
		"hurt":
			hurt = false
			$AnimatedSprite3D.play("idle")
