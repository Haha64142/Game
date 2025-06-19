extends Enemy

@export var MAX_SPEED := 10.0
@export var MIN_SPEED := 2.0

# For the speed equation
var _speed_slope: float
var _speed_intercept: float

var move_direction := Vector3.ZERO
var speed := 0.0

func _ready() -> void:
	add_to_group("Enemies")
	_find_speed_equation()


func _physics_process(delta: float) -> void:
	position += move_direction * speed * delta
	if collisions["Wall"]:
		position -= move_direction * speed * delta
		speed = 0.0


func _handle_hit(attack: String, node: Node3D) -> void:
	match attack:
		"Attack1":
			print("Hit by Attack1")
		
		"Arrow":
			move_direction = node.move_direction
			speed = _speed_slope * node.power + _speed_intercept
			print("Hit by Arrow")


func _find_speed_equation() -> void:
	_speed_slope = (MAX_SPEED - MIN_SPEED) / 0.9
	_speed_intercept = MAX_SPEED - _speed_slope
