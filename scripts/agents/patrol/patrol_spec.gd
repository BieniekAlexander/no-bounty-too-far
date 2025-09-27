## A struct of a region to patrol and the things to patrol for
class_name PatrolSpec

var region: PatrolRegion2D
var patrol_targets: Array

func _init(a_region: PatrolRegion2D, a_patrol_targets: Array) -> void:
	region = a_region
	patrol_targets = a_patrol_targets
