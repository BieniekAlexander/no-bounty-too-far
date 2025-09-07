extends CharacterBody2D

const SPEED: float = 5.0

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	var collision: KinematicCollision2D = move_and_collide(velocity)
	
	if collision:
		collision.get_collider().on_queue_free()
		queue_free()
