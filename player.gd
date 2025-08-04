extends CharacterBody3D

signal arrow_fired(shot_power: float, mouse_pos: Vector2, spawn_pos: Vector3)
signal attack1_finished()

enum AttackAnimation {
	None,
	Attack1,
	ShootAim,
	ShootFire,
}

@export_group("Attributes")
@export var health: int = 100

@export_subgroup("Weapons")
@export var damages: Dictionary[Global.AttackType, int] = {
	Global.AttackType.None: 0,
	Global.AttackType.Attack1: 50,
	Global.AttackType.Arrow: 30,
}

@export_subgroup("Movement")
@export var WALK_SPEED := 10.0
@export var ACCELERATION_SPEED := 30.0
@export var DECELERATION_SPEED := 50.0
@export var GRAVITY := 25.0
@export var TERMINAL_VELOCITY := 50.0

var attack: AttackAnimation = AttackAnimation.None
var _attack_queue: Array[AttackAnimation] = []

var prev_positions: Dictionary[int, Vector3] = {}

@onready var _attack1_hitboxes: Array[CollisionPolygon3D] = [
	$"Attack1/Attack1-0",
	$"Attack1/Attack1-1",
	$"Attack1/Attack1-2",
	$"Attack1/Attack1-3",
	$"Attack1/Attack1-4",
]

func _ready() -> void:
	Global.player_damages = damages
	
	for hitbox in _attack1_hitboxes:
		hitbox.disabled = true
	position = Global.respawn_pos
	prev_positions[int(GameTime.seconds * 100)] = position
	$AnimatedSprite3D.play("idle")


func _process(delta: float) -> void:
	prev_positions[int(GameTime.seconds * 100)] = position
	if prev_positions.size() > 500:
		var keys = prev_positions.keys()
		keys.sort()
		
		prev_positions.erase(keys[0])
	
	var direction := Vector2.ZERO

	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_forward", "move_back")
	direction = direction.normalized()
	if attack == AttackAnimation.Attack1:
		direction = Vector2.ZERO
	elif attack == AttackAnimation.ShootAim:
		direction /= 8
	
	if velocity.x < direction.x * WALK_SPEED:
		velocity.x = move_toward(velocity.x, direction.x * WALK_SPEED,
				ACCELERATION_SPEED * delta)
	if velocity.z < direction.y * WALK_SPEED:
		velocity.z = move_toward(velocity.z, direction.y * WALK_SPEED,
				ACCELERATION_SPEED * delta)
	if velocity.x > direction.x * WALK_SPEED:
		velocity.x = move_toward(velocity.x, direction.x * WALK_SPEED,
				DECELERATION_SPEED * delta)
	if velocity.z > direction.y * WALK_SPEED:
		velocity.z = move_toward(velocity.z, direction.y * WALK_SPEED,
				DECELERATION_SPEED * delta)
	
	if Input.is_action_just_pressed("attack"):
		_attack_queue.push_back(AttackAnimation.Attack1)
	
	if Input.is_action_just_pressed("shoot"):
		_attack_queue.push_back(AttackAnimation.ShootAim)
	
	if Input.is_action_just_pressed("reset_attack"):
		_attack_queue.clear()
	
	if attack == AttackAnimation.None:
		if not Global.mouse_visible:
			if Global.mouse_pos.x >= 480:
				$AnimatedSprite3D.flip_h = false
				$Attack1.scale.x = 1
			elif Global.mouse_pos.x < 480:
				$AnimatedSprite3D.flip_h = true
				$Attack1.scale.x = -1
		
		if abs(velocity.x) + abs(velocity.z) > 0:
			$AnimatedSprite3D.animation = "run"
		else:
			$AnimatedSprite3D.animation = "idle"
		
		if not _attack_queue.is_empty():
			match _attack_queue.pop_front():
				AttackAnimation.Attack1:
					$AnimatedSprite3D.play("attack1")
					attack = AttackAnimation.Attack1
				AttackAnimation.ShootAim:
					$AnimatedSprite3D.play("shoot_aim")
					$ShotTimer.start()
					attack = AttackAnimation.ShootAim
	
	elif attack == AttackAnimation.ShootAim:
		if not Global.mouse_visible:
			if Global.mouse_pos.x >= 480:
				$AnimatedSprite3D.flip_h = false
				$Attack1.scale.x = 1
			elif Global.mouse_pos.x < 480:
				$AnimatedSprite3D.flip_h = true
				$Attack1.scale.x = -1
		
		if !Input.is_action_pressed("shoot"):
			$AnimatedSprite3D.play("shoot_fire")
			arrow_fired.emit(1 - $ShotTimer.time_left / 0.7,
					Global.mouse_pos, position)
			attack = AttackAnimation.ShootFire
	
	
	velocity.y = maxf(-TERMINAL_VELOCITY, velocity.y - GRAVITY * delta)
	
	move_and_slide()
	Global.player_pos = position
	
	if position.y <= -20:
		position = Global.respawn_pos
		velocity = Vector3.ZERO


func update_circles(green_radius: float) -> void:
	# Red Circle
	$RedCircle.visible = Global.display_debug_circles
	
	# Green Circle
	$GreenCircle.mesh.top_radius = green_radius
	$GreenCircle.mesh.bottom_radius = green_radius
	$GreenCircle.visible = Global.display_debug_circles


func _on_hit_by_enemy(enemy: Enemy) -> void:
	print("Hit by Enemy")
	# Still need to make it do something.
	# I'm thinking I might have to make a state machine to make the code better


func _on_animated_sprite_3d_animation_finished() -> void:
	match $AnimatedSprite3D.animation:
		"attack1":
			_attack1_hitboxes[$AnimatedSprite3D.frame].disabled = true
			attack1_finished.emit()
			attack = AttackAnimation.None
			$AnimatedSprite3D.play("idle")
		
		"shoot_aim":
			if not Input.is_action_pressed("shoot"):
				$AnimatedSprite3D.play("shoot_fire")
				arrow_fired.emit(1 - $ShotTimer.time_left / 0.7,
						Global.mouse_pos, position)
				attack = AttackAnimation.ShootFire
		
		"shoot_fire":
			attack = AttackAnimation.None
			$AnimatedSprite3D.play("idle")


func _on_animated_sprite_3d_frame_changed() -> void:
	if $AnimatedSprite3D.animation != "attack1":
		return
	
	_attack1_hitboxes[$AnimatedSprite3D.frame].disabled = false
	_attack1_hitboxes[$AnimatedSprite3D.frame - 1].disabled = true
