class_name SoundPhysics

## Get how far the sound should travel, used in sound detection checks
static func get_audible_distance(emission_volume: float):
	# TODO this will surely need a more involved calculation :)
	return int(emission_volume)
