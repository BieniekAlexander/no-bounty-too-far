class_name RPG extends Equippable

const BULLET: PackedScene = preload("res://scenes/bullet.tscn")

func get_hud_text() -> String:
	return "ammo: %s" % count

func use(a_user: CharacterBody2D) -> void:
	if count>0:
		var new = BULLET.instantiate()
		a_user.add_child(new)
		new.fire(a_user.global_position, a_user.aim_direction)
		count -= 1
