class_name Equippable extends Node2D

const BULLET: PackedScene = preload("res://scenes/bullet.tscn")
var count: int = 5

#region HUD
@export var inventory_icon: Texture

func get_hud_text() -> String:
	return "ammo: %s" % count
#endregion

func use(a_user: CharacterBody2D) -> void:
	if count>0:
		var new = BULLET.instantiate()
		a_user.get_parent().add_child(new)
		new.fire(a_user)
		count -= 1
