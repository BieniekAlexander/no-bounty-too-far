class_name Goal

## TODO how much the agent cares about the objective
# maybe this should be a utility value rather than an enumeration?
var priority: int

## The truth variables related to the agent's goal
var facts: Array

## The action to perform that would fulfill this goal
var action: Action

func _init(a_action: Action, a_facts: Array = [], a_priority: int = 0) -> void:
	action = a_action
	facts = a_facts
	priority = a_priority

func udpate_facts(a_agent: Agent) -> void:
	for fact: Fact in facts:
		fact.update(a_agent)

func is_actionable() -> bool:
	return facts.all(func(f: Fact): return f.aware)

## Return the goal of killing a specified target
static func kill(a_object: Variant) -> Goal:
	return Goal.new(
		Action.shoot(a_object),
		[
			Fact.new(a_object, Fact.can_see)
		]
	)

## Return the goal of patrolling an area and looking for facts on [param a_objects]
static func patrol(a_patrol_spec: PatrolSpec) -> Goal:
	return Goal.new(
		Action.patrol(a_patrol_spec)
	)