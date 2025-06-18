extends Area3D

@export var MAX_SPEED := 25.0
@export var MIN_SPEED := 10.0

# For the speed equation 
var _speed_slope: float
var _speed_intercept: float

var move_direction := Vector3.ZERO
var speed: float

var power: float = 1

func _ready() -> void:
	_find_speed_equation()


func _physics_process(delta: float) -> void:
	position += move_direction * speed * delta
	if position.length() > 30:
		queue_free()


func shoot(shot_power: float, mouse_pos: Vector2, player_pos: Vector3) -> void:
	# get the mouse pos based on the center of the screen
	var new_mouse_pos := mouse_pos - Vector2(480, 256)
	if new_mouse_pos == Vector2.ZERO:
		new_mouse_pos = Vector2(1, 0)
	# multiply by -1 to flip the y-axis to match normal graph cords
	# multiply by 1.1412 to account for the camera tilt `1/sin(45°)`
	new_mouse_pos.y *= -1.4142
	
	rotation.y = atan2(new_mouse_pos.y, new_mouse_pos.x)
	move_direction.x = new_mouse_pos.normalized().x
	move_direction.z = -new_mouse_pos.normalized().y
	move_direction = move_direction.normalized()
	
	power = shot_power
	if power < 0.1:
		power = 0.1
	speed = _speed_slope * shot_power + _speed_intercept
	position = player_pos


func _find_speed_equation() -> void:
	_speed_slope = (MAX_SPEED - MIN_SPEED) / 0.9
	_speed_intercept = MAX_SPEED - _speed_slope


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Wall":
		queue_free()
