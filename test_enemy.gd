extends Area3D

var hit_by_attack1 : bool = false

func attack1_finished() -> void:
	hit_by_attack1 = false


func _on_body_shape_entered(_body_rid: RID, body: Node3D, body_shape_index: int, _local_shape_index: int) -> void:
	if body.name == "Floor":
		return
	if body.name != "Player":
		print(body.name)
		return
	var body_shape_owner = body.shape_find_owner(body_shape_index)
	var body_shape_node = body.shape_owner_get_owner(body_shape_owner)
	
	if body_shape_node.is_in_group("Attack1 Hitboxes") && hit_by_attack1 == false:
		hit_by_attack1 = true
		print("Hit by Attack1")


func _on_area_shape_entered(_area_rid: RID, area: Area3D, area_shape_index: int, _local_shape_index: int) -> void:
	var area_shape_owner = area.shape_find_owner(area_shape_index)
	var _area_shape_node = area.shape_owner_get_owner(area_shape_owner)
	
	if area.is_in_group("Arrows"):
		print("Hit by Arrow with power " + str(area.power))
