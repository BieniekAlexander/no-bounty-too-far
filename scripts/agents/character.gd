extends CharacterBody2D

#region children
@onready var actor: Node2D = $Actor
@onready var inventory: Node2D = $Inventory
#endregion

#region controls
@export var me: bool

var aim_direction: Vector2 = Vector2.LEFT
var aim_position: Vector2 = Vector2.ZERO
var equipment_index: int = 0

var movement_direction: Vector2 = Vector2.ZERO
var temp_rocket: bool = false # TODO just giving extra button, but controls will be reworked
var using_item: bool = false
var walking: bool = false
var peek_dir: Vector2 = Vector2.ZERO
var sight_position: Vector2:
	get: return global_position + peek_dir*20
#endregion

#region properties
const RUN_SPEED: float = 120.
const WALK_SPEED: float = 50.
@export var vision_radius: float = 50.
#endregion

#region HUD
func process_hud() -> void:
	if inventory.items[equipment_index]!=null:
		$"HUD/Label".text = inventory.items[equipment_index].get_hud_text()
	else:
		$"HUD/Label".text = ""
#endregion

### Interaction
var interactable: Node2D = null

#region Game Loop
func _ready() -> void:
	if me:
		add_to_group("player")
		remove_child($Agent)
	else:
		remove_child($HUD)
		add_to_group("foggable")

func _physics_process(_delta: float) -> void:
	physics_process_movement()
	physics_process_actions()
	
	actor.physics_process(_delta)

func _process(_delta: float) -> void:
	if me:
		input_movement()
		input_aim()
		input_equipment()
		process_hud()
		if Input.is_action_just_pressed("character_dialog"): temp_rocket = true
		if Input.is_action_just_pressed("character_use_item"): using_item = true
		
	process_aim()
#endregion

#region physics
func physics_process_movement() -> void:
	velocity = movement_direction * (WALK_SPEED if walking else RUN_SPEED)
	if peek_dir.dot(movement_direction)<0: peek_dir = Vector2.ZERO
	
	if peek_dir==Vector2.ZERO:
		move_and_slide()
		var collision: KinematicCollision2D = get_last_slide_collision()
		
		if collision:
			if check_peek(movement_direction, collision):
				peek_dir = movement_direction

## check if the character is peeking around a corner
func check_peek(a_movement_direction: Vector2, a_collision: KinematicCollision2D) -> bool:
	# Specifically, a character shall be said to peek around a corner if:
	# - they're running into a wall at a diagonal
	# - there is open space where the character's velocity projects onto the wall's direction
	if a_movement_direction==Vector2.ZERO or a_collision.get_normal().cross(a_movement_direction) in [0., 1., -1.]:
		return false
	
	var opening_direction = velocity.project(a_collision.get_normal().orthogonal()).normalized()
	var pp = PhysicsPointQueryParameters2D.new()
	pp.collision_mask = 1
	pp.exclude = [get_rid()]
	pp.position = global_position + opening_direction*16
	var adj_open: bool = get_viewport().find_world_2d().direct_space_state.intersect_point(pp, 1).is_empty()
	pp.position = global_position + a_movement_direction.normalized()*20
	var diag_open: bool = get_viewport().find_world_2d().direct_space_state.intersect_point(pp, 1).is_empty()
	return adj_open and diag_open

## Process the use of the item held by the character
func physics_process_actions() -> void:
	if using_item:
		using_item = false
		if $Inventory.items[equipment_index]!=null:
			$Inventory.items[equipment_index].use(self)
#endregion

#region input
func input_aim() -> void:
	aim_direction = (get_viewport().get_mouse_position() - global_position).normalized()
	aim_position = get_global_mouse_position()

func input_movement() -> void:
	movement_direction = Vector2(
		int(Input.is_action_pressed("character_move_right")) - int(Input.is_action_pressed("character_move_left")),
		int(Input.is_action_pressed("character_move_down")) - int(Input.is_action_pressed("character_move_up"))
	).normalized()
	
	if Input.is_action_just_pressed("character_toggle_walk"):
		walking = not walking

func input_equipment() -> void:
	if Input.is_action_just_pressed("character_equipment_1"): equipment_index = 1-1
	elif Input.is_action_just_pressed("character_equipment_2"): equipment_index = 2-1
	elif Input.is_action_just_pressed("character_equipment_3"): equipment_index = 3-1
	elif Input.is_action_just_pressed("character_equipment_4"): equipment_index = 4-1
	elif Input.is_action_just_pressed("character_equipment_5"): equipment_index = 5-1
	elif Input.is_action_just_pressed("character_equipment_6"): equipment_index = 6-1
	elif Input.is_action_just_pressed("character_equipment_7"): equipment_index = 7-1
#endregion

#region visuals
func process_aim() -> void:
	if abs(aim_direction.x) > abs(aim_direction.y): #its more horizontal than vertical
		$Sprite.frame = 2
		$Sprite.flip_h = aim_direction.x>0
	elif aim_direction.y > 0:
		$Sprite.frame = 0
	else:
		$Sprite.frame = 1
#endregion
