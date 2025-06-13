extends Area3D


func _on_body_entered(body: Node3D) -> void:
	print(body.name)


func _on_body_shape_entered(_body_rid: RID, body: Node3D, body_shape_index: int, _local_shape_index: int) -> void:
	if body.name == "Floor":
		return
	if body.name != "Player":
		print(body.name)
		return
	var body_shape_owner = body.shape_find_owner(body_shape_index)
	var body_shape_node = body.shape_owner_get_owner(body_shape_owner)
	
	if body_shape_node.is_in_group("Attack1 Hitboxes"):
		print("Hit by: " + body_shape_node.name)


func _on_area_shape_entered(_area_rid: RID, area: Area3D, area_shape_index: int, _local_shape_index: int) -> void:
	var area_shape_owner = area.shape_find_owner(area_shape_index)
	var area_shape_node = area.shape_owner_get_owner(area_shape_owner)
	
	print(area.name)
	print(area_shape_node.name)
