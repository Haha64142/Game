extends Enemy

var speed := 5.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
	init()
	add_to_group("Reg Enemies")
	
	nav_agent.call_deferred("set_target_position", Global.player_pos)


func _physics_process(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return
	
	var next_path_position := nav_agent.get_next_path_position()
	position = position.move_toward(next_path_position, delta * speed)


func _handle_hit(attack: String, node: Node3D) -> void:
	match attack:
		"Attack1":
			print("Hit by Attack1")
		
		"Arrow":
			print("Hit by Arrow")


func _on_navigation_agent_3d_navigation_finished() -> void:
	await get_tree().create_timer(0.5).timeout
	
	nav_agent.set_target_position(Global.player_pos)
