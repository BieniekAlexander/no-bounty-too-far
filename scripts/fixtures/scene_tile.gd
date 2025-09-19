extends Node2D

var dust: PackedScene = preload("res://scenes/dust_tile.tscn")

func on_queue_free():
	var new = dust.instantiate()
	get_parent().add_child(new)
	new.global_position = global_position
	queue_free()
