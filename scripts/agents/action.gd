## A high-level declaration of an action to perform
class_name Action

## The thing to be acted upon
var object: Variant

## The state modification that fulfills the action
var transition: Callable

func _init(a_object: Variant, a_transition: Callable) -> void:
	object = a_object
	transition = a_transition

static func shoot(a_object: Variant) -> Action:
	return Action.new(
		a_object,
		func(a_agent: Agent) -> void:
			a_agent.character.aim_direction = (a_object.global_position-a_agent.global_position).normalized()
			a_agent.character.using_item = true
	)

static func patrol(a_patrol_spec: PatrolSpec) -> Action:
	return Action.new(
		a_patrol_spec,
		func(a_agent: Agent) -> void:
			if a_agent.patrol_point==Vector2.INF:
				a_agent.nav_agent.set_target_position(a_agent.get_next_patrol_point(a_patrol_spec))

			for patrol_target: Variant in a_patrol_spec.patrol_targets:
				if Fact.can_see(a_agent, patrol_target):
					# TODO what the hell should I set this value to - the magnitude of suspicion change should probably vary according to the target
					# TODO add some sort of logic to have the suspicion metric decay
					a_patrol_spec.region.get_closest_polygon(patrol_target.global_position).suspicion += .05

			a_patrol_spec.region.get_closest_polygon(a_agent.global_position).staleness = 0.
	)
