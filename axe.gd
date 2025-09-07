extends Area3D

@export var MOVE_SPEED := 10.0
@export var ROT_SPEED := 10.0

var rot_direction: int = -1 # -1 to move right, 1 to move left
var move_direction := Vector3.ZERO
var speed := MOVE_SPEED

var is_stopped := false

var parent_orc: Area3D

func _ready() -> void:
	add_to_group("Axes", true)


func _physics_process(delta: float) -> void:
	if is_stopped:
		$Sprite3D.modulate = Color(Color.WHITE,
				$DeleteTimer.time_left / $DeleteTimer.wait_time)
	
	position += move_direction * speed * delta
	rotation.z += (speed / MOVE_SPEED) * ROT_SPEED * delta * rot_direction
	if position.length() > 100:
		queue_free()


func check_flip_h() -> void:
	if move_direction.x < 0:
		$Sprite3D.flip_h = true
		$Sprite3D.position.x = -$Sprite3D.position.x
		$CollisionShape3D.position.x = -$CollisionShape3D.position.x
		rot_direction = 1


func _on_body_shape_entered(_body_rid: RID, body: Node3D,
		body_shape_index: int, _local_shape_index: int) -> void:
	if body.is_in_group("Walls") or body.is_in_group("Floors"):
		speed = 0
		is_stopped = true
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)
		$DeleteTimer.start()
		return
	
	var body_shape_owner: int = body.shape_find_owner(body_shape_index)
	var body_shape_node: Node3D = body.shape_owner_get_owner(body_shape_owner)
	
	if body.name == "Player" and body_shape_node.is_in_group("Hitboxes"):
		parent_orc._hit_player()


func _on_delete_timer_timeout() -> void:
	queue_free()
