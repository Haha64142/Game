extends CharacterBody3D

var WALK_SPEED := 15.0
var ACCELERATION_SPEED := WALK_SPEED * 3.0
var GRAVITY := 25.0
var TERMINAL_VELOCITY := 50.0
var JUMP_HEIGHT = 8.0
var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO

	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_forward", "move_back")
	direction = direction.normalized()
	velocity.x = move_toward(velocity.x, direction.x * WALK_SPEED, ACCELERATION_SPEED * delta)
	velocity.z = move_toward(velocity.z, direction.y * WALK_SPEED, ACCELERATION_SPEED * delta)
	
	if Input.is_action_pressed("ui_accept"):
		velocity.y = JUMP_HEIGHT
	
	velocity.y = maxf(-TERMINAL_VELOCITY, velocity.y - GRAVITY * delta)
	
	move_and_slide()
