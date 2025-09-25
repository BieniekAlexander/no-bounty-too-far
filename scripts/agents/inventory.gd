extends Node2D

var items: Array = []
const TRAY_SIZE: int = 7 

func _ready() -> void:
	items.resize(TRAY_SIZE)
	items[0] = preload("res://scenes/equippables/gun.tscn").instantiate()
	items[1] = preload("res://scenes/equippables/stun_gun.tscn").instantiate()
	items[2] = preload("res://scenes/equippables/rpg.tscn").instantiate()
