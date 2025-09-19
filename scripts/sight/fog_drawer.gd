# source: https://didacromero.github.io/Fog-of-War/
extends Node2D

@onready var los_server = $'../../LOSServer'

var c: int = 0

func _ready() -> void:
	var fog_viewport: SubViewport = $'..'
	fog_viewport.size = los_server.world_size

func _process(_delta: float) -> void:
	queue_redraw()

#region visualization
func _draw():
	# Draw a texture representing visible vs previously seen regions, to be postprocessed by a shader
	draw_colored_polygon(los_server.world_boundary_points, Color(0,0,0,.5))
	
	if los_server.los_points.size()>0:
		draw_colored_polygon(los_server.los_points, Color.WHITE)
#endregion
