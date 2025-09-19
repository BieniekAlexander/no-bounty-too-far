extends CharacterBody2D

#region children
@onready var actor: Node2D = $Actor
@onready var inventory: Node2D = $Inventory
#endregion

#region controls
@export var me: bool

var aim_direction: Vector2 = Vector2.RIGHT
var aim_position: Vector2 = Vector2.ZERO
var equipment_index: int = 0

var movement_direction: Vector2 = Vector2.ZERO
var temp_rocket: bool = false # TODO just giving extra button, but controls will be reworked
var using_item: bool = false
var walking: bool = false
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
	move_and_slide()
	
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
