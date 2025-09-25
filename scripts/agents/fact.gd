## A statement about the game's world that an agent might know
class_name Fact

## The degree to which the agent knows of a fact
## e.g. the odds that an enemy is dangerous
var aware: bool = false

## The game entity that the fact pertains to
var object: Node

## A function to check against the object
var state_check: Callable

func _init(a_object: Node, a_state_check: Callable) -> void:
	object = a_object
	state_check = a_state_check

func update(a_agent: Agent) -> void:
		aware = state_check.call(a_agent, object)

static func visible(a_agent: Agent, a_target: Node) -> bool:
	a_agent.sight_ray.target_position = a_target.sight_position-a_agent.global_position

	if not a_agent.sight_ray.is_colliding() or a_agent.sight_ray.get_collider()==a_target:
		if abs(a_agent.sight_ray.target_position.angle_to(a_agent.character.aim_direction))<1.0:
			return true
	
	return false
