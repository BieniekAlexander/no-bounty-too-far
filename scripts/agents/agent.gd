class_name Agent extends Node2D

#region children
@onready var sight_ray: RayCast2D = $'../SightRay'
#endregion

#region agent
@onready var character: CharacterBody2D = $'..'
@onready var nav_agent: NavigationAgent2D = $NavigationAgent
@onready var goals: Array = [
	Goal.kill($'../../Player')
]
var player: CharacterBody2D
var shoot_delay: int = 90
var sees_target: bool = false
#endregion

const BULLET: PackedScene = preload("res://scenes/bullet.tscn")

#region game loop
func _ready() -> void:
	add_to_group("agent")
	sight_ray.add_exception_rid($'../Collider'.shape)
	nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func _physics_process(_delta: float) -> void:
	var actionable_goals: Array = []
	
	for goal: Goal in goals:
		goal.udpate_facts(self)
		
		if goal.is_actionable():
			actionable_goals.append(goal)
	
	if not goals.is_empty():
		var current_goal: Goal = goals[0]
		current_goal.action.transition.call(self)

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
