extends Area3D

@export var MAX_SPEED : float = 25.0
@export var MIN_SPEED : float = 10.0

# For the speed equation 
var speed_slope : float
var speed_intercept : float

var move_direction : Vector3 = Vector3.ZERO
var speed : float

func _physics_process(delta: float) -> void:
	position += move_direction * speed * delta

func shoot(shot_power: float, mouse_pos: Vector2, player_pos: Vector3) -> void:
	# get the mouse pos based on the center of the screen
	var new_mouse_pos : Vector2 = mouse_pos - Vector2(480, 256)
	if new_mouse_pos == Vector2.ZERO:
		new_mouse_pos = Vector2(1, 0)
	# multiply by -1 to flip the y-axis to match normal graph cords
	# multiply by 1.1412 to account for the camera tilt `1/sin(45°)`
	new_mouse_pos.y *= -1.4142
	
	rotation.y = atan2(new_mouse_pos.y, new_mouse_pos.x)
	move_direction.x = new_mouse_pos.normalized().x
	move_direction.z = -new_mouse_pos.normalized().y
	
	if shot_power < 0.1:
		shot_power = 0.1
	find_speed_equation()
	speed = speed_slope * shot_power + speed_intercept
	position = player_pos

func find_speed_equation() -> void:
	speed_slope = (MAX_SPEED - MIN_SPEED) / 0.9
	speed_intercept = MAX_SPEED - speed_slope
