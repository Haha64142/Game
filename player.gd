extends CharacterBody3D

signal shoot(mouse_pos, spawn_pos)

var WALK_SPEED := 10.0
var ACCELERATION_SPEED := WALK_SPEED * 3.0
var GRAVITY := 25.0
var TERMINAL_VELOCITY := 50.0
var JUMP_HEIGHT = 8.0

var attack := 0 # 0 - no attack, 1 - attack1, 2 - shoot_aim, 3 - shoot_fire
var attack_queue := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Global.respawn_pos
	$AnimatedSprite3D.play("idle")


func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO

	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_forward", "move_back")
	direction = direction.normalized()
	if attack == 1:
		direction = Vector2.ZERO
	elif attack == 2:
		direction /= 8
	
	velocity.x = move_toward(velocity.x, direction.x * WALK_SPEED, ACCELERATION_SPEED * delta)
	velocity.z = move_toward(velocity.z, direction.y * WALK_SPEED, ACCELERATION_SPEED * delta)
	
	
	if Input.is_action_just_pressed("attack"):
		attack_queue.push_back(1)
	
	if Input.is_action_just_pressed("shoot"):
		attack_queue.push_back(2)
	
	if Input.is_action_just_pressed("reset_attack"):
		attack_queue.clear()
	
	if attack == 0:
		if abs(velocity.x) + abs(velocity.z) > 0:
			$AnimatedSprite3D.animation = "run"
			
			if velocity.x > 0:
				$AnimatedSprite3D.flip_h = false
			elif velocity.x < 0:
				$AnimatedSprite3D.flip_h = true
		else:
			$AnimatedSprite3D.animation = "idle"
		
		if !attack_queue.is_empty():
			match attack_queue.pop_front():
				1:
					$AnimatedSprite3D.play("attack1")
					attack = 1
				2:
					$AnimatedSprite3D.play("shoot_aim")
					attack = 2
	
	elif attack == 2:
		if Global.mouse_visible == false:
			if Global.mouse_pos.x > 480:
				$AnimatedSprite3D.flip_h = false
			elif Global.mouse_pos.x < 480:
				$AnimatedSprite3D.flip_h = true
		
		if !Input.is_action_pressed("shoot"):
			$AnimatedSprite3D.play("shoot_fire")
			shoot.emit(Global.mouse_pos, position)
			attack = 3
	
	
	velocity.y = maxf(-TERMINAL_VELOCITY, velocity.y - GRAVITY * delta)
	
	move_and_slide()
	
	if position.y <= -20:
		position = Global.respawn_pos
		velocity = Vector3.ZERO


func _on_animated_sprite_3d_animation_finished() -> void:
	match $AnimatedSprite3D.animation:
		"attack1":
			attack = 0
			$AnimatedSprite3D.play("idle")
		
		"shoot_aim":
			if !Input.is_action_pressed("shoot"):
				$AnimatedSprite3D.play("shoot_fire")
				shoot.emit(Global.mouse_pos, position)
				attack = 3
		
		"shoot_fire":
			attack = 0
			$AnimatedSprite3D.play("idle")
