extends CharacterBody3D

signal arrow_fired(shot_power, mouse_pos, spawn_pos)
signal attack1_finished()

@export var WALK_SPEED := 10.0
@export var ACCELERATION_SPEED := 30.0
@export var DECELERATION_SPEED := 50.0
@export var GRAVITY := 25.0
@export var TERMINAL_VELOCITY := 50.0

var attack: int = 0 # 0 - no attack, 1 - attack1, 2 - shoot_aim, 3 - shoot_fire
var _attack_queue := []

@onready var _attack1_hitboxes := [
		$"Attack1/Attack1-0",
		$"Attack1/Attack1-1",
		$"Attack1/Attack1-2",
		$"Attack1/Attack1-3",
		$"Attack1/Attack1-4",
]

func _ready() -> void:
	for hitbox in _attack1_hitboxes:
		hitbox.disabled = true
	position = Global.respawn_pos
	$AnimatedSprite3D.play("idle")


func _process(delta: float) -> void:
	var direction := Vector2.ZERO

	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_forward", "move_back")
	direction = direction.normalized()
	if attack == 1:
		direction = Vector2.ZERO
	elif attack == 2:
		direction /= 8
	
	if velocity.x < direction.x * WALK_SPEED:
		velocity.x = move_toward(velocity.x, direction.x * WALK_SPEED, ACCELERATION_SPEED * delta)
	if velocity.z < direction.y * WALK_SPEED:
		velocity.z = move_toward(velocity.z, direction.y * WALK_SPEED, ACCELERATION_SPEED * delta)
	if velocity.x > direction.x * WALK_SPEED:
		velocity.x = move_toward(velocity.x, direction.x * WALK_SPEED, DECELERATION_SPEED * delta)
	if velocity.z > direction.y * WALK_SPEED:
		velocity.z = move_toward(velocity.z, direction.y * WALK_SPEED, DECELERATION_SPEED * delta)
	
	if Input.is_action_just_pressed("attack"):
		_attack_queue.push_back(1)
	
	if Input.is_action_just_pressed("shoot"):
		_attack_queue.push_back(2)
	
	if Input.is_action_just_pressed("reset_attack"):
		_attack_queue.clear()
	
	if attack == 0:
		if not Global.mouse_visible:
			if Global.mouse_pos.x >= 480:
				$AnimatedSprite3D.flip_h = false
			elif Global.mouse_pos.x < 480:
				$AnimatedSprite3D.flip_h = true
		
		if abs(velocity.x) + abs(velocity.z) > 0:
			$AnimatedSprite3D.animation = "run"
		else:
			$AnimatedSprite3D.animation = "idle"
		
		if not _attack_queue.is_empty():
			match _attack_queue.pop_front():
				1:
					$AnimatedSprite3D.play("attack1")
					attack = 1
				2:
					$AnimatedSprite3D.play("shoot_aim")
					$ShotTimer.start()
					attack = 2
	
	elif attack == 2:
		if not Global.mouse_visible:
			if Global.mouse_pos.x >= 480:
				$AnimatedSprite3D.flip_h = false
			elif Global.mouse_pos.x < 480:
				$AnimatedSprite3D.flip_h = true
		
		if !Input.is_action_pressed("shoot"):
			$AnimatedSprite3D.play("shoot_fire")
			arrow_fired.emit(1 - $ShotTimer.time_left / 0.7, Global.mouse_pos, position)
			attack = 3
	
	
	velocity.y = maxf(-TERMINAL_VELOCITY, velocity.y - GRAVITY * delta)
	
	move_and_slide()
	Global.player_pos = position
	
	if position.y <= -20:
		position = Global.respawn_pos
		velocity = Vector3.ZERO


func _on_animated_sprite_3d_animation_finished() -> void:
	match $AnimatedSprite3D.animation:
		"attack1":
			_attack1_hitboxes[$AnimatedSprite3D.frame].disabled = true
			attack1_finished.emit()
			attack = 0
			$AnimatedSprite3D.play("idle")
		
		"shoot_aim":
			if not Input.is_action_pressed("shoot"):
				$AnimatedSprite3D.play("shoot_fire")
				arrow_fired.emit(1 - $ShotTimer.time_left / 0.7, Global.mouse_pos, position)
				attack = 3
		
		"shoot_fire":
			attack = 0
			$AnimatedSprite3D.play("idle")


func _on_animated_sprite_3d_frame_changed() -> void:
	if $AnimatedSprite3D.animation != "attack1":
		return
	
	_attack1_hitboxes[$AnimatedSprite3D.frame].disabled = false
	
	if $AnimatedSprite3D.frame == 0:
		return
	_attack1_hitboxes[$AnimatedSprite3D.frame - 1].disabled = true
