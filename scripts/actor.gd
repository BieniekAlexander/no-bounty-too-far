extends Area2D

@onready var collider: CollisionShape2D = $Collider

var aim_position: Vector2 = Vector2.ZERO
var interactables: Array[Node2D] = []
func get_interactable() -> Node2D:
	return IU.argmin(
		interactables,
		func(a: Node): return (a.global_position - aim_position).length()
	)

func _input(event: InputEvent) -> void:
	var interactable: Node = get_interactable() 
	
	if event.is_action_pressed("character_interact") and interactable!=null:
		interactable.on_interact()

func physics_process(_delta: float) -> void:
	physics_process_aim()

func physics_process_aim() -> void:
	aim_position = get_viewport().get_mouse_position()

## Collision
func _on_area_entered(area: Area2D) -> void:
	interactables.append(area.get_parent())

func _on_area_exited(area: Area2D) -> void:
	interactables.erase(area.get_parent())
