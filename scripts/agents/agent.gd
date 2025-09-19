class_name Agent extends Node2D

#region children
@onready var ray: RayCast2D = $Ray
#endregion

#region agent
@onready var character: CharacterBody2D = $'..'
var player: CharacterBody2D
var shoot_delay: int = 90
var sees_target: bool = false
#endregion

const BULLET: PackedScene = preload("res://scenes/bullet.tscn")

func _ready() -> void:
	add_to_group("agent")
	ray.add_exception_rid($'../Collider'.shape)

func _physics_process(_delta: float) -> void:
	if player==null: return
	
	ray.global_position = global_position+(player.global_position-global_position).normalized() * 30
	ray.target_position = (player.global_position-global_position)
	sees_target = false
	
	# calculate visibility
	if ray.is_colliding() and ray.get_collider()==player:
		$'..'.show()
		if abs(ray.target_position.angle_to(character.aim_direction))<1.0:
			character.get_node("Sprite").self_modulate=Color.RED
			sees_target = true
		else:
			character.get_node("Sprite").self_modulate=Color.GREEN
	else:
		$'..'.hide()
	
	# calculate shot behavior - if enemy is in sights long enough
	if sees_target:
		shoot_delay -= 1
		if shoot_delay==0:
			var new = BULLET.instantiate()
			get_tree().root.add_child(new)
			new.fire(global_position, global_position.direction_to(player.global_position))
			shoot_delay = 90
			
	else:
		shoot_delay = 90
	
	
