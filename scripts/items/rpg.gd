class_name RPG extends Equippable

const ROCKET = preload('res://scenes/rocket.tscn')

func get_hud_text() -> String:
	return "rocket: %s" % count

func use(a_user: CharacterBody2D) -> void:
	if count>0:
		var new = ROCKET.instantiate()
		a_user.get_parent().add_child(new)
		new.fire(a_user.global_position, a_user.aim_direction)
		count -= 1
