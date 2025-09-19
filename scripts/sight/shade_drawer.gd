extends Node2D

@onready var los_server = $'../../LOSServer'

var c: int = 0

func _ready() -> void:
	var shade_viewport: SubViewport = $'..'
	shade_viewport.size = los_server.world_size

func _process(_delta: float) -> void:
	queue_redraw()
	
#region visualization
@onready var shade_texture_initialized: bool = false

func _draw():
	# Draw a texture representing visible vs invisible regions, to be postprocessed by a shader
	#if not fog_texture_initialized:
	if c<3: # TODO hack because the draw doesn't seem to immediately work
		c+=1
		draw_colored_polygon(los_server.world_boundary_points, Color.BLACK)
		shade_texture_initialized = true
	else:
		if los_server.los_points.size()>0:
			draw_colored_polygon(los_server.los_points, Color.WHITE)
#endregion
