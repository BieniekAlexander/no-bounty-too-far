## Class used to draw representations of a character's line of sight
class_name LineOfSightDrawer extends Node2D

@onready var los_server: LineOfSightServer = $'../../LOSServer'
@onready var sight_draw: Sprite2D = $'../../SightDraw'
var character: Character
var sight_polygon: PackedVector2Array

var c: int = 0

func _init(a_character: Character, a_los_server: LineOfSightServer) -> void:
	character = a_character
	los_server = a_los_server

func _ready() -> void:
	var sight_viewport: SubViewport = $'..'
	sight_viewport.size = los_server.world_size
	sight_draw.material.set_shader_parameter("vision_angle", character.find_child("Agent").vision_angle)

func _process(_delta: float) -> void:
	if character.find_child("Sprite").visible:
		sight_draw.material.set_shader_parameter("agent_position", character.global_position)
		sight_draw.material.set_shader_parameter("sight_vector", character.aim_direction)
		sight_polygon = los_server.get_visibility_polgygon_triples(
			los_server.fog_edges,
			character.global_position,
			character.vision_radius
		)

	queue_redraw()

#region visualization
func _draw():
	# Draw a texture representing the character's cone of vision
	# NOTE: the draw gets processed in the shader to a set opacity
	# because overlapping draw calls would lead to too much opacity
	if character.find_child("Sprite").visible and sight_polygon.size()>0:
		draw_colored_polygon(sight_polygon, Color.BLACK)
#endregion
