extends Enemy

var speed := 5.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
	initialize()
	add_to_group("Orcs")
	
	nav_agent.set_target_position(Global.player_pos)


func _physics_process(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return
	
	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	position = position.move_toward(next_path_position, delta * speed)


func _handle_hit(attack: AttackType, node: Node3D) -> void:
	match attack:
		AttackType.Attack1:
			print("Hit by Attack1")
		
		AttackType.Arrow:
			print("Hit by Arrow")


func _on_navigation_agent_3d_navigation_finished() -> void:
	await get_tree().create_timer(0.5).timeout
	
	nav_agent.set_target_position(Global.player_pos)
