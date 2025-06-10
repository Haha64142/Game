extends Area3D

@export var speed: float = 20.0
var move_direction := Vector3.ZERO

func shoot(mouse_pos: Vector2) -> void:
	# get the mouse pos based on the center of the screen
	var new_mouse_pos = mouse_pos - Vector2(480, 256)
	if new_mouse_pos == Vector2.ZERO:
		new_mouse_pos = Vector2(1, 0)
	# multiply by -1 to flip the y-axis to match normal graph cords
	# multiply by 1.1412 to account for the camera tilt `1/sin(45°)`
	new_mouse_pos.y *= -1.4142
	rotation.y = atan2(new_mouse_pos.y, new_mouse_pos.x)
	move_direction.x = new_mouse_pos.normalized().x
	move_direction.z = -new_mouse_pos.normalized().y

func _physics_process(delta: float) -> void:
	position += move_direction * speed * delta
