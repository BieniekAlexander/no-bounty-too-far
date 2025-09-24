extends Area2D

@export var duration: int = 15
var caster: Character

func _physics_process(_delta: float) -> void:
	duration -= 1
	
	if duration == 0:
		queue_free()

func _on_body_entered(_body: Node2D):
	if _body==caster:
		print("skip")
	else:
		print("stuff inside")

func fire(a_user: Character, a_range: float=30):
	global_position = a_user.global_position+a_user.aim_direction*a_range
	caster = a_user
