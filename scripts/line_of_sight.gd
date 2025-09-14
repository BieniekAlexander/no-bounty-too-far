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
	fog_grid = generate_fog_grid(
		ground_tiles.get_used_rect().size,
		Vector2i.ZERO,
		ground_tiles.tile_set.tile_size.x
	)
	
	var fog_edges: Array = generate_fog_edge_map(
		fog_grid,
		16
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

## Generate the grid which describes the visibility obstructions of a space
func generate_fog_grid(a_dimensions: Vector2i, a_space_top_left: Vector2i, a_cell_width: int) -> Array:
	var ret: Array = Array()
	
	# notice the range extension for bounding cells, which will always "obstruct view" for LOS calculation
	for i in range(-1, a_dimensions.x+1):
		var row: Array = []
		
		for j in range(-1, a_dimensions.y+1):
			row.append(
				FogCell.new(
					a_space_top_left + Vector2i(i, j)*a_cell_width,
					a_cell_width,
					i==-1 or i==a_dimensions.x or j==-1 or j==a_dimensions.y
				)
			)
		
		ret.append(row)
	
	var pp = PhysicsPointQueryParameters2D.new()
	pp.position = Vector2.ONE*float(a_cell_width)/2
	pp.collision_mask = 8
	
	for row in ret:
		for cell in row:
			if cell.bounding:
				cell.obstructs = true
			else:
				pp.position = cell.tl + Vector2i.ONE*a_cell_width/2
			
				if ground_tiles.get_viewport().find_world_2d().direct_space_state.intersect_point(pp, 1):
					cell.obstructs = true
	
	return ret

## Calculate the segments representing line of sight edges
func generate_fog_edge_map(fog_grid: Array, f_block_width: float) -> Array:
	var ret: Array = []

	for row: Array in fog_grid:
		for cell: FogCell in row:
			for dir: int in CD.values():
				cell.edge_ids[dir] = NO_EDGE
	
	var dimensions: Vector2i = Vector2i(
		fog_grid.size(),
		fog_grid[0].size()
	)
	
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			var index: Vector2i = Vector2i(x, y)
			var north: Vector2i = index + NEIGHBOR_INDEX_OFFSET_MAP[CD.N]
			var west: Vector2i = index + NEIGHBOR_INDEX_OFFSET_MAP[CD.W]
			
			for direction in NEIGHBOR_INDEX_OFFSET_MAP.keys():
				var cell: FogCell = fog_grid[index.x][index.y]
				var neighbor: Vector2i = index + NEIGHBOR_INDEX_OFFSET_MAP[direction]
				if neighbor.x<0 or neighbor.x>=dimensions.x or neighbor.y<0 or neighbor.y>=dimensions.y: continue
				
				# If this cell exists, check if it needs edges
				if fog_grid[x][y].obstructs:
					# if no neighbor exists, represent an edge here
					if not fog_grid[neighbor.x][neighbor.y].obstructs:
						#region west check
						if direction==CD.W:
							# northern neighbor has west edge, so extend that as our edge
							if fog_grid[north.x][north.y].edge_ids[CD.W]!=NO_EDGE:
								ret[fog_grid[north.x][north.y].edge_ids[CD.W]].end.y += f_block_width
								fog_grid[index.x][index.y].edge_ids[CD.W] = fog_grid[north.x][north.y].edge_ids[CD.W]
							# northern neighbor doesn't have west edge, so we start a new one
							else:
								var edge: FogEdge = FogEdge.new(cell.tl, cell.bl)
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
								var edge: FogEdge = FogEdge.new(cell.tr, cell.br)
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
								var edge: FogEdge = FogEdge.new(cell.tl, cell.tr)
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
								var edge: FogEdge = FogEdge.new(cell.bl, cell.br)
								var edge_id: int = ret.size()
								ret.push_back(edge)
								fog_grid[index.x][index.y].edge_ids[CD.S] = edge_id
						#endregion
	#print(ret)
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
