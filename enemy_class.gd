extends Area3D
class_name Enemy

## If [code]false[/code], the node is hidden and doesn't use collisions
@export var enabled := true

@export_group("Attributes")
@export var health: int = 10
@export var damage: int = 10

var collisions := {
	"FloorInt": 0,
	"WallInt": 0,
	"PlayerInt": 0,
	"Attack1Int": 0,
	"ArrowInt": 0,
	"Floor": false,
	"Wall": false,
	"Player": false,
	"Attack1": false,
	"Arrow": false,
}

var _hit_by_attack1 := false

func _init() -> void:
	add_to_group("Enemies")


## Virtual function that triggers when the enemy gets hit
func _handle_hit(_attack: String, _node: Node3D) -> void:
	pass


## Virtual function that triggers when the enemy hits the player
func _hit_player() -> void:
	pass


## Virtual function that trigger with any new collision
func _handle_collision(_node: Node3D, _shape_index: int) -> void:
	pass


## Function to be called in the [method Node._ready] function
func init() -> void:
	visible = enabled
	monitoring = enabled
	monitorable = enabled


# Called by the arena node
func attack1_finished() -> void:
	_hit_by_attack1 = false


func update_collisions_dict() -> void:
	var half_size: int = collisions.size() / 2
	var keys := collisions.keys()
	for i in range(half_size):
		if collisions[keys[i]] > 0:
			collisions[keys[i + half_size]] = true
		else:
			collisions[keys[i + half_size]] = false


func _on_body_shape_entered(_body_rid: RID, body: Node3D, body_shape_index: int, _local_shape_index: int) -> void:
	if body == null:
		return
	_handle_collision(body, body_shape_index)
	
	if body.name == "Floor" or body.name == "Wall":
		collisions[body.name + "Int"] += 1
		update_collisions_dict()
		return
	if body.name != "Player":
		return
	
	var body_shape_owner = body.shape_find_owner(body_shape_index)
	var body_shape_node = body.shape_owner_get_owner(body_shape_owner)
	
	if body_shape_node.is_in_group("Player Hitbox"):
		collisions["PlayerInt"] += 1
		update_collisions_dict()
		_hit_player()


func _on_body_shape_exited(_body_rid: RID, body: Node3D, body_shape_index: int, _local_shape_index: int) -> void:
	if body == null:
		return
	
	if body.name == "Floor" or body.name == "Wall":
		collisions[body.name + "Int"] -= 1
		update_collisions_dict()
		return
	if body.name != "Player":
		return
	
	var body_shape_owner = body.shape_find_owner(body_shape_index)
	var body_shape_node = body.shape_owner_get_owner(body_shape_owner)
	
	if body_shape_node.is_in_group("Player Hitbox"):
		collisions["PlayerInt"] -= 1
		update_collisions_dict()


func _on_area_shape_entered(_area_rid: RID, area: Area3D, area_shape_index: int, _local_shape_index: int) -> void:
	if area == null:
		return
	_handle_collision(area, area_shape_index)
	
	var area_shape_owner = area.shape_find_owner(area_shape_index)
	var area_shape_node = area.shape_owner_get_owner(area_shape_owner)
	
	if area.is_in_group("Arrows"):
		collisions["ArrowInt"] += 1
		update_collisions_dict()
		_handle_hit("Arrow", area)
	elif area.is_in_group("Attack1"):
		collisions["Attack1Int"] += 1
		update_collisions_dict()
		if not _hit_by_attack1:
			_hit_by_attack1 = true
			_handle_hit("Attack1", area)


func _on_area_shape_exited(_area_rid: RID, area: Area3D, area_shape_index: int, _local_shape_index: int) -> void:
	if area == null:
		return
	
	var area_shape_owner = area.shape_find_owner(area_shape_index)
	var area_shape_node = area.shape_owner_get_owner(area_shape_owner)
	
	if area.is_in_group("Arrows"):
		collisions["ArrowInt"] -= 1
		update_collisions_dict()
	elif area.is_in_group("Attack1"):
		collisions["Attack1Int"] -= 1
		update_collisions_dict()
