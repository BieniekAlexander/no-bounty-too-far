class_name StunGun extends Equippable

const SHOCK = preload('res://scenes/shock.tscn')

func get_hud_text() -> String:
	return "charges: %s" % count

func use(a_user: CharacterBody2D) -> void:
	if count>0:
		var new = SHOCK.instantiate()
		a_user.get_parent().add_child(new)
		new.fire(a_user)
		count -= 1
