class_name Agent extends Node2D

#region children
@onready var ray: RayCast2D = $Ray
#endregion

#region agent
@onready var character: CharacterBody2D = $'..'
@onready var nav_agent: NavigationAgent2D = $NavigationAgent
var player: CharacterBody2D
var shoot_delay: int = 90
var sees_target: bool = false
#endregion

const BULLET: PackedScene = preload("res://scenes/bullet.tscn")

#region game loop
func _ready() -> void:
	add_to_group("agent")
	ray.add_exception_rid($'../Collider'.shape)
	nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func _physics_process(_delta: float) -> void:
	if player==null: return
	
	ray.global_position = global_position
	ray.target_position = (player.global_position-global_position)
	sees_target = false
	
	# calculate visibility
	if ray.is_colliding() and ray.get_collider()==player:
		$'..'.show()
		if abs(ray.target_position.angle_to(character.aim_direction))<1.0:
			character.get_node("Sprite").self_modulate=Color.RED
			sees_target = true
		else:
			character.get_node("Sprite").self_modulate=Color.GREEN
	else:
		$'..'.hide()
	
	# calculate shot behavior - if enemy is in sights long enough
	if sees_target:
		get_parent().aim_direction = get_parent().global_position.direction_to(player.global_position)
		shoot_delay -= 1
		if shoot_delay==0:
			var new = BULLET.instantiate()
			get_tree().root.add_child(new)
			new.fire(global_position, global_position.direction_to(player.global_position))
			shoot_delay = 90
		
		nav_agent.set_target_position(player.global_position)
	else:
		shoot_delay = 90
	
	process_navigation()
#endregion

#region navigation
## calculate the desired position of the agent against the navmesh
func process_navigation() -> void:
	if NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0 or nav_agent.is_navigation_finished():
		return
	
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	nav_agent.set_velocity(global_position.direction_to(next_path_position) * get_parent().RUN_SPEED/30)

## Callback that performs the movement udpate according to the navmesh
func _on_velocity_computed(safe_velocity: Vector2) -> void:
	get_parent().global_position = global_position.move_toward(global_position + safe_velocity, get_parent().RUN_SPEED/30)
#endregion
