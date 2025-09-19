extends CharacterBody2D

@export var SPEED: float = 5.0
@export var breaks_stuff: bool = false

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	var collision: KinematicCollision2D = move_and_collide(velocity)
	
	if collision:
		if breaks_stuff: collision.get_collider().on_queue_free()
		queue_free()

func fire(a_origin: Vector2, a_aim_direction: Vector2, a_range: float=20):
	global_position = a_origin+a_aim_direction*a_range
	velocity = SPEED * a_aim_direction.normalized()
	rotation = a_aim_direction.angle()
