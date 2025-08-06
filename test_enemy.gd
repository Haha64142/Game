extends Enemy

@export var MAX_SPEED := 10.0
@export var MIN_SPEED := 2.0

# For the speed equation
var speed_slope: float
var speed_intercept: float

var move_direction := Vector3.ZERO

func _ready() -> void:
	initialize()
	_find_speed_equation()


func _physics_process(delta: float) -> void:
	position += move_direction * speed * delta
	if collisions["Wall"]:
		position -= move_direction * speed * delta
		speed = 0.0


func _handle_hit(attack: Global.AttackType, node: Node3D) -> void:
	match attack:
		Global.AttackType.Attack1:
			print("Hit by Attack1")
		
		Global.AttackType.Arrow:
			move_direction = node.move_direction
			speed = speed_slope * node.power + speed_intercept
			print("Hit by Arrow")


func _find_speed_equation() -> void:
	speed_slope = (MAX_SPEED - MIN_SPEED) / 0.9
	speed_intercept = MAX_SPEED - speed_slope
