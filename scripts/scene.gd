extends Node2D

func _ready() -> void:
	for agent: Agent in get_tree().get_nodes_in_group("agent"):
		agent.player = get_tree().get_nodes_in_group("player")[0]
