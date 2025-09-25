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
		func(a_agent: Agent):
			a_agent.character.aim_direction = (a_object.global_position-a_agent.global_position).normalized()
			a_agent.character.using_item = true
	)
	
