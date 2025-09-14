# source: https://didacromero.github.io/Fog-of-War/
extends Node2D

#region world info
@onready var character: CharacterBody2D = $"../../Character"
@onready var ground_tiles: TileMapLayer = $"../../Terrain"
@onready var tile_size: int = ground_tiles.tile_set.tile_size.x
#endregion

#region LOS
# fog calculations
## cardinal directions
enum CD {N=0, S=1, E=2, W=3}
const NO_EDGE: int = -1
var fog_grid: Array = []
var visibility_polygon_triples: Array
var los_points: PackedVector2Array
var world_boundary_points: PackedVector2Array
const NEIGHBOR_INDEX_OFFSET_MAP: Dictionary[int, Vector2i] = {
	CD.N: Vector2i(0, -1),
	CD.S: Vector2i(0, +1),
	CD.W: Vector2i(-1, 0),
	CD.E: Vector2i(+1, 0)
}
#endregion

func _ready() -> void:
	var world_size: Vector2i = ground_tiles.get_used_rect().size * tile_size
	world_boundary_points = PackedVector2Array()
	world_boundary_points.append(Vector2(0,0))
	world_boundary_points.append(world_size*Vector2i(1,0))
	world_boundary_points.append(world_size)
	world_boundary_points.append(world_size*Vector2i(0,1))

func _physics_process(_delta: float) -> void:
	#if fog_grid == []: # TODO collisions not instantly working, idk why, so I run this every frame
	fog_grid = generate_fog_grid()
	var fog_edges: Array = generate_fog_edge_map(
		0,
		0,
		ground_tiles.get_used_rect().size.x,
		ground_tiles.get_used_rect().size.y,
		16,
		0    
	)
	
	visibility_polygon_triples = get_visibility_polgygon_triples(fog_edges, character.global_position.x, character.global_position.y, 50)
	# TODO remove adjacent, similar rays
	los_points = PackedVector2Array(
		visibility_polygon_triples.map(
			func(triple: Vector3) -> Vector2: return Vector2(triple.x, triple.y)
		)
	)
	
	if los_points.size()>0:
		queue_redraw()
	else:
		push_error("failed to calc LOS")

## Generate the grid which describes the 
func generate_fog_grid() -> Array:
	var dimensions: Vector2i = ground_tiles.get_used_rect().size
	var tile_size: int = ground_tiles.tile_set.tile_size.x
	var ret: Array = Array()
	
	for i in range(dimensions.x):
		ret.append([])
		
		for j in range(dimensions.y):
			ret[i].append(FogCell.new())
	
	var pp = PhysicsPointQueryParameters2D.new()
	pp.position = Vector2.ONE*float(tile_size)/2
	pp.collision_mask = 8
	
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			pp.position = Vector2.ONE*float(tile_size)/2 + Vector2(x, y)*tile_size
			
			if ground_tiles.get_viewport().find_world_2d().direct_space_state.intersect_point(pp, 1):
				ret[x][y].exist = true
	
	return ret

## Calculate the segments representing line of sight edges
func generate_fog_edge_map(sx: int, sy: int, w: int, h: int, f_block_width: float, pitch: int) -> Array:
	var ret: Array = []

	for row: Array in fog_grid:
		for cell: FogCell in row:
			for dir: int in CD.values():
				cell.edge_ids[dir] = NO_EDGE
	
	var dimensions: Vector2i = ground_tiles.get_used_rect().size
	
	for x in range(w):
		for y in range(h):
			var index: Vector2i = Vector2i(x, y)
			var north: Vector2i = index + NEIGHBOR_INDEX_OFFSET_MAP[CD.N]
			var south: Vector2i = index + NEIGHBOR_INDEX_OFFSET_MAP[CD.S]
			var west: Vector2i = index + NEIGHBOR_INDEX_OFFSET_MAP[CD.W]
			var east: Vector2i = index + NEIGHBOR_INDEX_OFFSET_MAP[CD.E]
			
			for direction in NEIGHBOR_INDEX_OFFSET_MAP.keys():
				var neighbor: Vector2i = index + NEIGHBOR_INDEX_OFFSET_MAP[direction]
				
				# If this cell exists, check if it needs edges
				if fog_grid[x][y].exist:
					# if no neighbor exists, represent an edge here
					if not fog_grid[neighbor.x][neighbor.y].exist:
						#region west check
						if direction==CD.W:
							# northern neighbor has west edge, so extend that as our edge
							if fog_grid[north.x][north.y].edge_ids[CD.W]!=NO_EDGE:
								ret[fog_grid[north.x][north.y].edge_ids[CD.W]].end.y += f_block_width
								fog_grid[index.x][index.y].edge_ids[CD.W] = fog_grid[north.x][north.y].edge_ids[CD.W]
							# northern neighbor doesn't have west edge, so we start a new one
							else:
								var edge: FogEdge = FogEdge.new(
									Vector2((sx + x) * f_block_width, (sy + y) * f_block_width),
									Vector2((sx + x) * f_block_width, (sy + y + 1) * f_block_width)
								)
								
								var edge_id: int = ret.size()
								ret.push_back(edge)
								fog_grid[index.x][index.y].edge_ids[CD.W] = edge_id
						#endregion
						#region east check
						elif direction==CD.E:
							if fog_grid[north.x][north.y].edge_ids[CD.E]!=NO_EDGE:
								ret[fog_grid[north.x][north.y].edge_ids[CD.E]].end.y += f_block_width
								fog_grid[index.x][index.y].edge_ids[CD.E] = fog_grid[north.x][north.y].edge_ids[CD.E]
							else:
								var edge: FogEdge = FogEdge.new(
									Vector2((sx + x + 1) * f_block_width, (sy + y) * f_block_width),
									Vector2((sx + x + 1) * f_block_width, (sy + y + 1) * f_block_width)
								)
								
								var edge_id: int = ret.size()
								ret.push_back(edge)
								fog_grid[index.x][index.y].edge_ids[CD.E] = edge_id
						#endregion
						#region north check
						elif direction==CD.N:
							if fog_grid[west.x][west.y].edge_ids[CD.N]!=NO_EDGE:
								ret[fog_grid[west.x][west.y].edge_ids[CD.N]].end.x += f_block_width
								fog_grid[index.x][index.y].edge_ids[CD.N] = fog_grid[west.x][west.y].edge_ids[CD.N]
							else:
								var edge: FogEdge = FogEdge.new(
									Vector2((sx + x) * f_block_width, (sy + y) * f_block_width),
									Vector2((sx + x + 1) * f_block_width, (sy + y) * f_block_width)
								)
								
								var edge_id: int = ret.size()
								ret.push_back(edge)
								fog_grid[index.x][index.y].edge_ids[CD.N] = edge_id
						#endregion
						#region south check
						elif direction==CD.S:
							if fog_grid[west.x][west.y].edge_ids[CD.S]!=NO_EDGE:
								ret[fog_grid[west.x][west.y].edge_ids[CD.S]].end.x += f_block_width
								fog_grid[index.x][index.y].edge_ids[CD.S] = fog_grid[west.x][west.y].edge_ids[CD.S]
							else:
								var edge: FogEdge = FogEdge.new(
									Vector2((sx + x) * f_block_width, (sy + y + 1) * f_block_width),
									Vector2((sx + x + 1) * f_block_width, (sy + y + 1) * f_block_width)
								)
								
								var edge_id: int = ret.size()
								ret.push_back(edge)
								fog_grid[index.x][index.y].edge_ids[CD.S] = edge_id
						#endregion
	
	return ret

## Get the triples representing the visibility polygonsm given a view obstructing edge set
func get_visibility_polgygon_triples(a_fog_edges: Array, ox: float, oy: float, radius: float) -> Array:
	var ret: Array = []
	
	for e1 in a_fog_edges:
		# Take the start point, then the end point
		for i in range(2):
			var rdx = (e1.start.x if i == 0 else e1.end.x) - ox
			var rdy = (e1.start.y if i == 0 else e1.end.y) - oy

			var base_ang = atan2(rdy, rdx)

			# For each point, cast 3 rays, 1 directly at point and 1 a little either side
			for j in range(3):
				var ang: float
				if j == 0:
					ang = base_ang - 0.0001
				elif j == 1:
					ang = base_ang
				else:
					ang = base_ang + 0.0001

				# Create ray along angle for required distance
				rdx = radius * cos(ang)
				rdy = radius * sin(ang)

				var min_t1 = INF
				var min_px = 0.0
				var min_py = 0.0
				var min_ang = 0.0
				var valid = false

				# Check for ray intersection with all edges
				for e2 in a_fog_edges:
					# Create line segment vector
					var sdx = e2.end.x - e2.start.x
					var sdy = e2.end.y - e2.start.y

					if abs(sdx - rdx) > 0.0 and abs(sdy - rdy) > 0.0:
						# t2 is normalised distance along line segment
						var t2 = (rdx * (e2.start.y - oy) + (rdy * (ox - e2.start.x))) / (sdx * rdy - sdy * rdx)
						# t1 is normalised distance along ray
						var t1 = (e2.start.x + sdx * t2 - ox) / rdx

						# If intersect point exists along ray and within line segment
						if t1 > 0 and t2 >= 0 and t2 <= 1.0:
							# Check if this intersection is closest
							if t1 < min_t1:
								min_t1 = t1
								min_px = ox + rdx * t1
								min_py = oy + rdy * t1
								min_ang = atan2(min_py - oy, min_px - ox)
								valid = true

				# Add intersection point to visibility polygon perimeter
				if valid:
					ret.append(Vector3(min_px, min_py, min_ang))

	# Sort perimeter los_points by angle from source (for triangle fan rendering)
	ret.sort_custom(
		func(a, b): return a.z < b.z
	)
	
	return ret
#endregion

#region Fog
func _draw():
	# Draw a texture representing visible and invisible regions,
	# to be postprocessed by a shader
	if los_points.size()>0:
		draw_colored_polygon(world_boundary_points, Color.BLACK)
		draw_colored_polygon(los_points, Color.WHITE)
#endregion
