extends CharacterBody3D

signal arrow_fired(shot_power: float, mouse_pos: Vector2, spawn_pos: Vector3)
signal attack1_finished()
signal player_dead()

enum State {
	Idle,
	Run,
	Hurt,
	Dead,
	Attack1,
	ShootAim,
	ShootFire,
	Paused,
}

enum AttackType {
	None,
	Attack1,
	Arrow,
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

var prev_state := State.Idle
var state := State.Idle

var new_state := State.Idle
var importance: int = 0 # 1 overrides 0 or 1, but not a 2
var state_changed := false

var shot_timer := 0.0

var damage_taken: int = 0
var dead = false
var invincible := 0.0

var attack_queue: Array[AttackType] = []
var prev_positions: Dictionary[int, Vector3] = {}

@onready var attack1_hitboxes: Array[CollisionPolygon3D] = [
	$"Attack1/Attack1-0",
	$"Attack1/Attack1-1",
	$"Attack1/Attack1-2",
	$"Attack1/Attack1-3",
	$"Attack1/Attack1-4",
]

func _ready() -> void:
	Global.player_damages = damages
	
	for hitbox in attack1_hitboxes:
		hitbox.disabled = true
	position = Global.respawn_pos
	prev_positions[int(GameTime.seconds * 100)] = position
	
	$AnimatedSprite3D.play("idle")


func _process(delta: float) -> void:
	match state:
		State.Idle:
			update_common_vars(delta)
			
			move(delta)
			if abs(velocity.x) + abs(velocity.z) > 0:
				change_state(State.Run, 0)
			
			look_toward_mouse()
			if $AnimatedSprite3D.animation != "idle":
				$AnimatedSprite3D.play("idle")
			
			match get_attack():
				AttackType.Attack1:
					change_state(State.Attack1, 1)
				AttackType.Arrow:
					change_state(State.ShootAim, 1)
		
		State.Run:
			update_common_vars(delta)
			
			move(delta)
			if abs(velocity.x) + abs(velocity.z) == 0:
				change_state(State.Idle, 0)
			
			look_toward_mouse()
			if $AnimatedSprite3D.animation != "run":
				$AnimatedSprite3D.play("run")
			
			match get_attack():
				AttackType.Attack1:
					change_state(State.Attack1, 1)
				AttackType.Arrow:
					change_state(State.ShootAim, 1)
		
		State.Hurt:
			update_common_vars(delta)
			
			move(delta, 0)
			
			if prev_state != State.Hurt:
				$AnimatedSprite3D.play("hurt")
				health -= damage_taken
				damage_taken = 0
		
		State.Dead:
			if dead == false:
				$AnimatedSprite3D.play("death")
				player_dead.emit()
				dead = true
		
		State.Attack1:
			update_common_vars(delta)
			
			move(delta, 0)
			
			if prev_state != State.Attack1:
				$AnimatedSprite3D.play("attack1")
		
		State.ShootAim:
			update_common_vars(delta)
			
			if prev_state == State.ShootAim:
				shot_timer += delta
			else:
				shot_timer = delta
			
			move(delta, 0.125)
			
			look_toward_mouse()
			if $AnimatedSprite3D.animation != "shoot_aim":
				$AnimatedSprite3D.play("shoot_aim")
			
			update_gravity_only(delta)
			
			if not Input.is_action_pressed("shoot"):
				change_state(State.ShootFire, 1)
		
		State.ShootFire:
			update_common_vars(delta)
			
			move(delta)
			
			if prev_state != State.ShootFire:
				var shot_power = min(shot_timer / 0.7, 1)
				arrow_fired.emit(shot_power, Global.mouse_pos, position)
				$AnimatedSprite3D.play("shoot_fire")
		
		State.Paused:
			pass
	
	prev_state = state
	if state_changed:
		state = new_state
		importance = 0
		state_changed = false


func change_state(to_state: State, new_importance: int) -> void:
	if new_importance < importance:
		return
	new_state = to_state
	importance = new_importance
	state_changed = true


func move(delta: float, speed_multiplier := 1.0) -> void:
	var direction = get_direction(speed_multiplier)
	velocity = get_new_velocity(direction, velocity, delta)
	update_position()


func update_common_vars(delta: float) -> void:
	update_prev_positions()
	update_attack_queue()
	invincible = max(invincible - delta, 0)


func update_circles(green_radius: float) -> void:
	# Red Circle
	$RedCircle.visible = Global.display_debug_circles
	
	# Green Circle
	$GreenCircle.mesh.top_radius = green_radius
	$GreenCircle.mesh.bottom_radius = green_radius
	$GreenCircle.visible = Global.display_debug_circles


func update_prev_positions() -> void:
	prev_positions[int(GameTime.seconds * 100)] = position
	if prev_positions.size() > 500:
		var keys = prev_positions.keys()
		keys.sort()
		
		prev_positions.erase(keys[0])


func get_direction(speed_multiplier: float) -> Vector2:
	var direction := Vector2.ZERO
	
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_forward", "move_back")
	direction = direction.normalized()
	direction *= speed_multiplier
	
	return direction


func get_new_velocity(direction: Vector2, old_velocity: Vector3,
		delta: float) -> Vector3:
	var new_velocity := old_velocity
	
	if old_velocity.x < direction.x * WALK_SPEED:
		new_velocity.x = move_toward(old_velocity.x, direction.x * WALK_SPEED,
				ACCELERATION_SPEED * delta)
	elif old_velocity.x > direction.x * WALK_SPEED:
		new_velocity.x = move_toward(old_velocity.x, direction.x * WALK_SPEED,
				DECELERATION_SPEED * delta)
	
	if old_velocity.z < direction.y * WALK_SPEED:
		new_velocity.z = move_toward(old_velocity.z, direction.y * WALK_SPEED,
				ACCELERATION_SPEED * delta)
	elif old_velocity.z > direction.y * WALK_SPEED:
		new_velocity.z = move_toward(old_velocity.z, direction.y * WALK_SPEED,
				DECELERATION_SPEED * delta)
	
	new_velocity.y = maxf(-TERMINAL_VELOCITY, old_velocity.y - GRAVITY * delta)
	
	return new_velocity


func update_attack_queue() -> void:
	if Input.is_action_just_pressed("attack"):
		attack_queue.push_back(AttackType.Attack1)
	
	if Input.is_action_just_pressed("shoot"):
		attack_queue.push_back(AttackType.Arrow)
	
	if Input.is_action_just_pressed("reset_attack"):
		attack_queue.clear()


func look_toward_mouse() -> void:
	if Global.mouse_pos.x >= 480:
		$AnimatedSprite3D.flip_h = false
		$Attack1.scale.x = 1
	elif Global.mouse_pos.x < 480:
		$AnimatedSprite3D.flip_h = true
		$Attack1.scale.x = -1


func get_attack() -> AttackType:
	match attack_queue.pop_front():
		AttackType.Attack1:
			return AttackType.Attack1
		AttackType.Arrow:
			return AttackType.Arrow
		_:
			return AttackType.None


func update_position() -> void:
	move_and_slide()
	Global.player_pos = position
	
	if position.y <= -20:
		position = Global.respawn_pos
		velocity = Vector3.ZERO


func update_gravity_only(delta: float) -> void:
	var old_velocity = velocity
	velocity = Vector3(0,
			get_new_velocity(Vector2.ZERO, velocity, delta).y, 0)
	update_position()
	velocity = old_velocity


func _on_hit_by_enemy(enemy: Enemy) -> void:
	if invincible > 0:
		return
	damage_taken = enemy.attack_damage
	change_state(State.Hurt, 2)
	invincible = 2
	print("Hit by Enemy")


func _on_animated_sprite_3d_animation_finished() -> void:
	match $AnimatedSprite3D.animation:
		"attack1":
			attack1_hitboxes[$AnimatedSprite3D.frame].disabled = true
			attack1_finished.emit()
			change_state(State.Idle, 0)
		
		"shoot_fire":
			change_state(State.Idle, 0)
		
		"hurt":
			if health <= 0:
				change_state(State.Dead, 2)
			else:
				change_state(State.Idle, 0)


func _on_animated_sprite_3d_frame_changed() -> void:
	if $AnimatedSprite3D.animation != "attack1":
		return
	
	attack1_hitboxes[$AnimatedSprite3D.frame].disabled = false
	attack1_hitboxes[$AnimatedSprite3D.frame - 1].disabled = true
