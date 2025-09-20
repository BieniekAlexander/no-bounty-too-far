# source: https://didacromero.github.io/Fog-of-War/
extends Node2D

#region world info
@onready var player: CharacterBody2D = $"../Player"
@onready var ground_tiles: TileMapLayer = $"../Terrain"
@onready var tile_size: int = ground_tiles.tile_set.tile_size.x
@onready var world_size: Vector2i = ground_tiles.get_used_rect().size * tile_size
#endregion

#region LOS
# fog calculations
## cardinal directions
enum CD {N=0, S=1, E=2, W=3}
const NO_EDGE: int = -1
var fog_grid: Array = []
var fog_edges: Array = []
var visibility_polygon_triples: Array
var los_points: PackedVector2Array
var world_boundary_points: PackedVector2Array
const NEIGHBOR_INDEX_OFFSET_MAP: Dictionary[int, Vector2i] = {
	CD.N: Vector2i(0, -1),
	CD.S: Vector2i(0, +1),
	CD.W: Vector2i(-1, 0),
	CD.E: Vector2i(+1, 0)
}

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
static func generate_fog_edge_map(a_fog_grid: Array, f_block_width: float) -> Array:
	var ret: Array = []

	for row: Array in a_fog_grid:
		for cell: FogCell in row:
			for dir: int in CD.values():
				cell.edge_ids[dir] = NO_EDGE
	
	var dimensions: Vector2i = Vector2i(
		a_fog_grid.size(),
		a_fog_grid[0].size()
	)
	
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			var index: Vector2i = Vector2i(x, y)
			var north: Vector2i = index + NEIGHBOR_INDEX_OFFSET_MAP[CD.N]
			var west: Vector2i = index + NEIGHBOR_INDEX_OFFSET_MAP[CD.W]
			
			for direction in NEIGHBOR_INDEX_OFFSET_MAP.keys():
				var neighbor_index: Vector2i = index + NEIGHBOR_INDEX_OFFSET_MAP[direction]
				var cell: FogCell = a_fog_grid[index.x][index.y]
				if neighbor_index.x<0 or neighbor_index.x>=dimensions.x or neighbor_index.y<0 or neighbor_index.y>=dimensions.y: continue
				
				# If this cell exists, check if it needs edges
				if a_fog_grid[x][y].obstructs:
					# if no neighbor exists, represent an edge here
					if not a_fog_grid[neighbor_index.x][neighbor_index.y].obstructs:
						#region west check
						if direction==CD.W:
							# northern neighbor has west edge, so extend that as our edge
							if a_fog_grid[north.x][north.y].edge_ids[CD.W]!=NO_EDGE:
								ret[a_fog_grid[north.x][north.y].edge_ids[CD.W]].end.y += f_block_width
								a_fog_grid[index.x][index.y].edge_ids[CD.W] = a_fog_grid[north.x][north.y].edge_ids[CD.W]
							# northern neighbor doesn't have west edge, so we start a new one
							else:
								var edge: FogEdge = FogEdge.new(cell.tl, cell.bl)
								var edge_id: int = ret.size()
								ret.push_back(edge)
								a_fog_grid[index.x][index.y].edge_ids[CD.W] = edge_id
						#endregion
						#region east check
						elif direction==CD.E:
							if a_fog_grid[north.x][north.y].edge_ids[CD.E]!=NO_EDGE:
								ret[a_fog_grid[north.x][north.y].edge_ids[CD.E]].end.y += f_block_width
								a_fog_grid[index.x][index.y].edge_ids[CD.E] = a_fog_grid[north.x][north.y].edge_ids[CD.E]
							else:
								var edge: FogEdge = FogEdge.new(cell.tr, cell.br)
								var edge_id: int = ret.size()
								ret.push_back(edge)
								a_fog_grid[index.x][index.y].edge_ids[CD.E] = edge_id
						#endregion
						#region north check
						elif direction==CD.N:
							if a_fog_grid[west.x][west.y].edge_ids[CD.N]!=NO_EDGE:
								ret[a_fog_grid[west.x][west.y].edge_ids[CD.N]].end.x += f_block_width
								a_fog_grid[index.x][index.y].edge_ids[CD.N] = a_fog_grid[west.x][west.y].edge_ids[CD.N]
							else:
								var edge: FogEdge = FogEdge.new(cell.tl, cell.tr)
								var edge_id: int = ret.size()
								ret.push_back(edge)
								a_fog_grid[index.x][index.y].edge_ids[CD.N] = edge_id
						#endregion
						#region south check
						elif direction==CD.S:
							if a_fog_grid[west.x][west.y].edge_ids[CD.S]!=NO_EDGE:
								ret[a_fog_grid[west.x][west.y].edge_ids[CD.S]].end.x += f_block_width
								a_fog_grid[index.x][index.y].edge_ids[CD.S] = a_fog_grid[west.x][west.y].edge_ids[CD.S]
							else:
								var edge: FogEdge = FogEdge.new(cell.bl, cell.br)
								var edge_id: int = ret.size()
								ret.push_back(edge)
								a_fog_grid[index.x][index.y].edge_ids[CD.S] = edge_id
						#endregion
	
	return ret

## Get the triples representing the visibility polygons, given a view obstructing edge set
func get_visibility_polgygon_triples(a_fog_edges: Array, a_position: Vector2, a_radius: float, a_delta: float = .1, a_epsilon: float = 0.0001) -> Array:
	var ret: Array = []
	
	for e1 in a_fog_edges:
		# Take the start point, then the end point
		for i in range(2):
			var rd = (e1.start if (i == 0) else e1.end) - a_position
			var base_ang = atan2(rd.y, rd.x)

			# For each point, cast 3 rays, 1 directly at point and 1 a little either side
			for j in range(-1, 2):
				var ang: float = base_ang + j*a_epsilon

				# Create ray along angle for required distance
				rd = a_radius * Vector2(cos(ang), sin(ang))

				var min_t1 = INF
				var min_px = 0.0
				var min_py = 0.0
				var min_ang = 0.0
				var valid = false

				# Check for ray intersection with all edges
				for e2 in a_fog_edges:
					# Create line segment vector
					var sd: Vector2 = e2.end - e2.start

					if abs(sd.x - rd.x) > 0.0 and abs(sd.y - rd.y) > 0.0:
						# t2 is normalised distance along line segment
						var t2 = (rd.x * (e2.start.y - a_position.y) + (rd.y * (a_position.x - e2.start.x))) / (sd.x * rd.y - sd.y * rd.x)
						# t1 is normalised distance along ray
						var t1 = (e2.start.x + sd.x * t2 - a_position.x) / rd.x

						# If intersect point exists along ray and within line segment
						if t1 > 0 and t2 >= 0 and t2 <= 1.0:
							# Check if this intersection is closest
							if t1 < min_t1:
								min_t1 = t1
								min_px = a_position.x + rd.x * t1
								min_py = a_position.y + rd.y * t1
								min_ang = atan2(min_py - a_position.y, min_px - a_position.x)
								valid = true

				# Add intersection point to visibility polygon perimeter
				if valid:
					ret.append(Vector3(min_px, min_py, min_ang))

	# Sort perimeter los_points by angle from source (for triangle fan rendering)
	ret.sort_custom(
		func(a, b): return a.z < b.z
	)
	
	# deduplicate points that are very close to eachother
	for i in range(ret.size()-1, -1, -1):
		if abs(ret[i].x-ret[i-1].x)<a_delta and abs(ret[i].y-ret[i-1].y)<a_delta:
			ret.remove_at(i)
	
	return ret
#endregion

#region node
func _ready() -> void:
	world_boundary_points = PackedVector2Array()
	world_boundary_points.append(Vector2(0,0))
	world_boundary_points.append(world_size*Vector2i(1,0))
	world_boundary_points.append(world_size)
	world_boundary_points.append(world_size*Vector2i(0,1))

func _physics_process(_delta: float) -> void:
	if fog_edges.size()<=4: # TODO collisions not instantly working, idk why, so I run this every frame
		fog_grid = generate_fog_grid(
			ground_tiles.get_used_rect().size,
			Vector2i.ZERO,
			tile_size
		)
		
		fog_edges = generate_fog_edge_map(
			fog_grid,
			tile_size
		)
	
	visibility_polygon_triples = get_visibility_polgygon_triples(
		fog_edges,
		player.sight_position,
		player.vision_radius
	)
	
	los_points = PackedVector2Array(
		visibility_polygon_triples.map(
			func(triple: Vector3) -> Vector2: return Vector2(triple.x, triple.y)
		)
	)
#endregion
