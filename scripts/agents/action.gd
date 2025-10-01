## A high-level declaration of an action to perform. Actions are performed by applying a [member Action.transition] function
## to an [Agent], updating the [Agent]'s state so as to fulfill the action on the [member Action.object]
class_name Action

## The thing to be acted upon
var object: Variant

## The state transition that, when applied to an agent, updates their behavior so as to fulfill the action
var transition: Callable

func _init(a_object: Variant, a_transition: Callable) -> void:
	object = a_object
	transition = a_transition

## Return an action of looking at the target object
static func look(a_object: Variant) -> Action:
	return Action.new(
		a_object,
		func(a_agent: Agent) -> void:
			a_agent.nav_agent.target_position = a_agent.global_position
			a_agent.character.aim_direction = (a_object.global_position-a_agent.global_position).normalized()
	)

## Return an action of shooting at the target object
static func shoot(a_object: Variant) -> Action:
	return Action.new(
		a_object,
		func(a_agent: Agent) -> void:
			a_agent.nav_agent.target_position = a_agent.global_position
			a_agent.character.aim_direction = (a_object.global_position-a_agent.global_position).normalized()
			a_agent.character.using_item = true
	)

## Return a patrolling action based on the supplied [PatrolSpec]
static func patrol(a_patrol_spec: PatrolSpec) -> Action:
	return Action.new(
		a_patrol_spec,
		func(a_agent: Agent) -> void:
			if a_agent.patrol_point==Vector2.INF:
				var next_patrol_point: Vector2 = a_agent.get_next_patrol_point(a_patrol_spec)
				a_agent.nav_agent.set_target_position(next_patrol_point)
				a_agent.character.aim_direction = (next_patrol_point-a_agent.global_position).normalized()
			
			for i in range(a_patrol_spec.patrol_targets.size()-1, -1, -1):
				var patrol_target: Variant = a_patrol_spec.patrol_targets[i]
				
				if is_instance_valid(patrol_target):
					if Fact.can_see(a_agent, patrol_target):
						# TODO what the hell should I set this value to - the magnitude of suspicion change should probably vary according to the target
						# TODO add some sort of logic to have the suspicion metric decay
						a_patrol_spec.region.get_closest_polygon(patrol_target.global_position).suspicion += .05
				else:
					a_patrol_spec.patrol_targets.remove_at(i)

			a_patrol_spec.region.get_closest_polygon(a_agent.global_position).staleness = 0.
	)
