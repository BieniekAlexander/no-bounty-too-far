## A statement about the game's world that an agent might know
class_name Fact

## A meter used to gradually bring facts to the agent's attention,
## e.g. a gradual noticing that an enemy is in vision
var awareness: float = 0.0
var awareness_decay: float = 0.0

## The game entity that the fact pertains to
var object: Variant

## True if there's no object of this fact, used to account for Fact freeing behavior
var intransitive: bool

## A function to check against the object
var state_check: Callable

func _init(a_object: Variant, a_state_check: Callable, a_awareness_decay: float = 0.0) -> void:
	object = a_object
	intransitive = a_object==null
	state_check = a_state_check
	awareness_decay = a_awareness_decay

func update_awareness(a_agent: Agent) -> void:
	var gain: float = state_check.call(a_agent, object)

	if gain > 0.0:
		awareness = min(state_check.call(a_agent, object)+awareness, 1.0)
	else:
		awareness = max(awareness-awareness_decay, 0.0)
		print(awareness)

## Check whether the given [param a_agent] can see the [param a_target], according to raycasts against the obstruction collision layer
static func can_see(a_agent: Agent, a_target: Variant) -> float:
	a_agent.sight_ray.target_position = a_target.global_position-a_agent.global_position
	a_agent.sight_ray.force_raycast_update()

	if not a_agent.sight_ray.is_colliding():
		if abs(a_agent.sight_ray.target_position.angle_to(a_agent.character.aim_direction))<1.0:
			return 1.0/(Engine.physics_ticks_per_second)
	
	return 0.0

## A fact state check function that always returns full awareness
static func always_aware() -> Fact:
	return Fact.new(null, func(_a_agent: Agent, _a_target: Variant) -> float: return 1.0)
