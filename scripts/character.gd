extends CharacterBody2D

### Children
@onready var actor: Node2D = $Actor

### Movement
const RUN_SPEED: float = 120.
const WALK_SPEED: float = 50.
var walking: bool = false

### Aim
@export_category("Aim")
@export var vision_diameter: int = 150
var aim_direction: Vector2 = Vector2.RIGHT
var aim_position: Vector2 = Vector2.ZERO

### Inventory
const ROCKET: PackedScene = preload("res://scenes/rocket.tscn")

### Interaction
var interactable: Node2D = null

#region REPL
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("character_toggle_walk"):
		walking = not walking

func physics_process_aim() -> void:
	aim_direction = (get_viewport().get_mouse_position() - global_position).normalized()
	aim_position = get_global_mouse_position()

func physics_process_movement() -> void:
	velocity = Vector2(
		int(Input.is_action_pressed("character_move_right")) - int(Input.is_action_pressed("character_move_left")),
		int(Input.is_action_pressed("character_move_down")) - int(Input.is_action_pressed("character_move_up"))
	).normalized() * (WALK_SPEED if walking else RUN_SPEED)
	move_and_slide()
	
## Process the use of the item held by the character
func physics_process_use() -> void:
	if Input.is_action_just_pressed("character_use_item"):
		var new = ROCKET.instantiate()
		get_tree().root.add_child(new)
		new.global_position = global_position+aim_direction*20
		new.velocity = new.SPEED * aim_direction.normalized()

func _physics_process(_delta: float) -> void:
	physics_process_aim()
	physics_process_movement()
	physics_process_use()
	ray()
	
	actor.physics_process(_delta)

func process(_delta: float) -> void:
	process_aim()
	
	actor.process(_delta)
#endregion

func process_aim() -> void:
	if abs(aim_direction.x) > abs(aim_direction.y): #its more horizontal than vertical
		$Sprite.frame = 2
		$Sprite.flip_h = aim_direction.x>0
	elif aim_direction.y > 0:
		$Sprite.frame = 0
	else:
		$Sprite.frame = 1

func ray() -> void:
	$RayCast2D.global_position = global_position
	$RayCast2D.target_position = aim_direction*vision_diameter
	$RayCast2D.force_raycast_update()

	if $RayCast2D.is_colliding():
		pass
		#"the grid map" is actually an object reference, not a string.
		#if $RayCast2D.get_collider() == "the grid map":
			#pass
			##proceed to add the block.
