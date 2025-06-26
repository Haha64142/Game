class_name Enemy
extends Area3D
## Class to use for all enemies. It contains methods to handle collisions
## 
## You must [method initialize] an [Enemy] in [method Node._ready]
## to use collisions. You can toggle [member enabled] to toggle visibilty
## and collisions.
## [br][br]
## [method _handle_hit], [method _hit_player], and [method _handle_collision]
## are all virtual methods that help handle collisions.

enum AttackType {
	None,
	Attack1,
	Arrow,
}

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


## Called when this [Enemy] gets hit by the Player.
## [param attack] specifies the [enum Enemy.AttackType] of the attack.
## [param attack] will always be either [constant Attack1] or [constant Arrow].
## [param node] is the node that hit this [Enemy].
## [param node] can be a [Node3D], [Area3D], or [GridMap].
## [br][br]
## [b]Note:[/b] You must [method initialize] an enemy to use collisions.
func _handle_hit(_attack: AttackType, _node: Node3D) -> void:
	pass


## Called when the [Enemy] hits the Player.
## [br][br]
## [b]Note:[/b] You must [method initialize] an enemy to use collisions.
func _hit_player() -> void:
	pass


## Called with any new collision.
## [param node] is the node that hit this [Enemy].
## [param node] can be a [Node3D], [Area3D], or [GridMap].
## [param shape_index] is the index of the shape that overlaps this [Enemy].
## [br][br]
## [b]Example:[/b] Get the [CollisionShape3D] node from the [param shape_index]:
## [codeblock]
## var shape_owner_id = node.shape_find_owner(shape_index)
## var collision_node = node.shape_owner_get_owner(shape_owner_id)
## [/codeblock][br]
## [b]Note:[/b] You must [method initialize] an enemy to use collisions.
func _handle_collision(_node: Node3D, _shape_index: int) -> void:
	pass


## Function that needs to be called in [method Node._ready].
## If [method initialize] isn't called, this [Enemy] won't process collision
func initialize() -> void:
	visible = enabled
	monitoring = enabled
	monitorable = enabled
	
	body_shape_entered.connect(_on_body_shape_entered)
	body_shape_exited.connect(_on_body_shape_exited)
	area_shape_entered.connect(_on_area_shape_entered)
	area_shape_exited.connect(_on_area_shape_exited)


## Called by the arena node to allow this node to be able
## to be hit by attack1 again. Without the [member _hit_by_attack1] variable,
## it would say it was hit each time the player's collision shape changed
func attack1_finished() -> void:
	_hit_by_attack1 = false


func update_collisions_dict() -> void:
	var half_size: int = collisions.size() / 2
	var keys: Array[String] = collisions.keys()
	for i in range(half_size):
		if collisions[keys[i]] > 0:
			collisions[keys[i + half_size]] = true
		else:
			collisions[keys[i + half_size]] = false


func _on_body_shape_entered(_body_rid: RID, body: Node3D,
		body_shape_index: int, _local_shape_index: int) -> void:
	if body == null:
		return
	_handle_collision(body, body_shape_index)
	
	if body.name == "Floor" or body.name == "Wall":
		collisions[body.name + "Int"] += 1
		update_collisions_dict()
		return
	if body.name != "Player":
		return
	
	var body_shape_owner: int = body.shape_find_owner(body_shape_index)
	var body_shape_node: Node3D = body.shape_owner_get_owner(body_shape_owner)
	
	if body_shape_node.is_in_group("Player Hitbox"):
		collisions["PlayerInt"] += 1
		update_collisions_dict()
		_hit_player()


func _on_body_shape_exited(_body_rid: RID, body: Node3D,
		body_shape_index: int, _local_shape_index: int) -> void:
	if body == null:
		return
	
	if body.name == "Floor" or body.name == "Wall":
		collisions[body.name + "Int"] -= 1
		update_collisions_dict()
		return
	if body.name != "Player":
		return
	
	var body_shape_owner: int = body.shape_find_owner(body_shape_index)
	var body_shape_node: Node3D = body.shape_owner_get_owner(body_shape_owner)
	
	if body_shape_node.is_in_group("Player Hitbox"):
		collisions["PlayerInt"] -= 1
		update_collisions_dict()


func _on_area_shape_entered(_area_rid: RID, area: Area3D,
		area_shape_index: int, _local_shape_index: int) -> void:
	if area == null:
		return
	_handle_collision(area, area_shape_index)
	
	var area_shape_owner: int = area.shape_find_owner(area_shape_index)
	var area_shape_node: Node3D = area.shape_owner_get_owner(area_shape_owner)
	
	if area.is_in_group("Arrows"):
		collisions["ArrowInt"] += 1
		update_collisions_dict()
		_handle_hit(AttackType.Arrow, area)
	elif area.is_in_group("Attack1"):
		collisions["Attack1Int"] += 1
		update_collisions_dict()
		if not _hit_by_attack1:
			_hit_by_attack1 = true
			_handle_hit(AttackType.Attack1, area)


func _on_area_shape_exited(_area_rid: RID, area: Area3D,
		area_shape_index: int, _local_shape_index: int) -> void:
	if area == null:
		return
	
	var area_shape_owner: int = area.shape_find_owner(area_shape_index)
	var area_shape_node: Node3D = area.shape_owner_get_owner(area_shape_owner)
	
	if area.is_in_group("Arrows"):
		collisions["ArrowInt"] -= 1
		update_collisions_dict()
	elif area.is_in_group("Attack1"):
		collisions["Attack1Int"] -= 1
		update_collisions_dict()
