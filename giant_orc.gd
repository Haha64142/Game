extends Enemy

var hurt := false
var dead := false

var player: CharacterBody3D
var player_pos := Vector3.ZERO

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
	initialize()
	add_to_group("Orcs")
	
	nav_agent.set_target_position(Global.player_pos)


func _physics_process(delta: float) -> void:
	if hurt or dead:
		return
	
	player_pos = player.position
	nav_agent.set_target_position(player_pos)
	
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


func _handle_hit(attack: Global.AttackType, node: Node3D) -> void:
	if hurt or dead:
		return
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


func _on_animated_sprite_3d_animation_finished() -> void:
	match $AnimatedSprite3D.animation:
		"hurt":
			hurt = false
			$AnimatedSprite3D.play("idle")
