## Class used to draw representations of a character's line of sight
class_name LineOfSightDrawer extends Node2D

@onready var los_server: LineOfSightServer = $'../../LOSServer'
var character: Character
var sight_polygon: PackedVector2Array

var c: int = 0

func _init(a_character: Character, a_los_server: LineOfSightServer) -> void:
	character = a_character
	los_server = a_los_server

func _ready() -> void:
	var sight_viewport: SubViewport = $'..'
	sight_viewport.size = los_server.world_size
	print(sight_viewport.size)

func _process(_delta: float) -> void:
	if character.find_child("Sprite").visible:
		sight_polygon = los_server.get_visibility_polgygon_triples(
			los_server.fog_edges,
			character.global_position,
			character.vision_radius
		)

	queue_redraw()

#region visualization
func _draw():
	# Draw a texture representing the character's cone of vision
	if character.find_child("Sprite").visible and sight_polygon.size()>0:
		draw_colored_polygon(sight_polygon, Color(0.76, 0.114, 0.329, 0.2))
#endregion
