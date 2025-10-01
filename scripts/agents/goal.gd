class_name Goal

## Integer allowing for prioritization of currently considered goals
enum PRIORITY {
	## Goals to be pursued if there's nothing else to do
	FALLBACK = 0,
	## Low Priority
	LOW = 1,
	## High Priority
	HIGH = 2,
	## Goals regarding safety and such?
	CRITICAL = 3
}

## TODO how much the agent cares about the objective
# maybe this should be a utility value rather than an enumeration?
var priority: PRIORITY

## The truth variables related to the agent's goal
var precondition_thresholds: Dictionary

## The action to perform that would fulfill this goal
var action: Action

func _init(a_action: Action, a_precondition_thresholds: Dictionary = {Fact.always_aware(): 1.}, a_priority: PRIORITY = PRIORITY.FALLBACK) -> void:
	action = a_action
	precondition_thresholds = a_precondition_thresholds
	priority = a_priority

func update_facts(a_agent: Agent) -> void:
	for fact in precondition_thresholds.keys():
		if fact.intransitive or is_instance_valid(fact.object):
			fact.update_awareness(a_agent)
		else:
			precondition_thresholds.erase(fact)

## Returns whether the goal's action should be performed, based on the factual preconditions being met
func is_actionable() -> bool:
	# Notice that actionability is false if there are no facts to observe, which is meant to account for the case
	# when a goal can't be actionable if there are no such facts to observe (and so there's not really an object to act on)
	return precondition_thresholds.keys().all(func(f: Fact): return f.awareness>=precondition_thresholds[f]) if precondition_thresholds.size()>0 else false

## Return the goal of killing a specified target
static func kill(a_object: Variant) -> Goal:
	return Goal.new(
		Action.shoot(a_object),
		{Fact.new(a_object, Fact.can_see, 1./(10.*Engine.physics_ticks_per_second)): 1.},
		PRIORITY.HIGH
	)

static func look(a_object: Variant) -> Goal:
	return Goal.new(
		Action.look(a_object),
		{Fact.new(a_object, Fact.can_see, 1./(10.*Engine.physics_ticks_per_second)): .1},
		PRIORITY.HIGH
	)

## Return the goal of patrolling an area and looking for facts on [param a_objects]
static func patrol(a_patrol_spec: PatrolSpec) -> Goal:
	return Goal.new(
		Action.patrol(a_patrol_spec)
	)
