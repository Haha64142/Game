extends Area3D

@export var MAX_SPEED := 25.0
@export var MIN_SPEED := 10.0

var SCREEN_WIDTH: int = ProjectSettings.get_setting(
		"display/window/size/viewport_width")
var SCREEN_HEIGHT: int = ProjectSettings.get_setting(
		"display/window/size/viewport_height")

var move_direction := Vector3.ZERO
var speed := 0.0
var power := 1.0 # 0.1 - 1

var is_stopped := false

# For the speed equation 
var speed_slope: float
var speed_intercept: float

func _ready() -> void:
	add_to_group("Arrows", true)
	_find_speed_equation()


func _physics_process(delta: float) -> void:
	if is_stopped:
		$Sprite3D.modulate = Color(Color.WHITE,
				$DeleteTimer.time_left / $DeleteTimer.wait_time)
		$Sprite3D2.modulate = Color(Color.WHITE,
				$DeleteTimer.time_left / $DeleteTimer.wait_time)
	position += move_direction * speed * delta
	if position.length() > 100:
		queue_free()


func shoot(shot_power: float, mouse_pos: Vector2, player_pos: Vector3) -> void:
	# get the mouse pos based on the center of the screen
	var new_mouse_pos := mouse_pos - Vector2(
			SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)
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
	speed = speed_slope * shot_power + speed_intercept
	position = player_pos


func _find_speed_equation() -> void:
	speed_slope = (MAX_SPEED - MIN_SPEED) / 0.9
	speed_intercept = MAX_SPEED - speed_slope


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Wall":
		speed = 0
		is_stopped = true
		set_deferred("monitorable", false)
		$DeleteTimer.start()


func _on_delete_timer_timeout() -> void:
	queue_free()
