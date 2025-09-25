class_name PatrolPolygon

var neighbors: Set
var vertex_indices: Set
var bound_locations: PackedVector2Array
var centroid: Vector2
var interest: float = 0.0

func _init(
	a_vertex_indices: Set,
	a_bound_locations: PackedVector2Array,
	a_neighbors: Set = Set.new()
) -> void:
	neighbors = a_neighbors
	bound_locations = a_bound_locations
	vertex_indices = a_vertex_indices
	centroid = get_centroid(bound_locations)

func is_connected_to(a_other: PatrolPolygon) -> bool:
	return vertex_indices.intersection(a_other.vertex_indices).size()>=2

func contains_point(a_point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(a_point, bound_locations)

static func get_centroid(a_points: PackedVector2Array) -> Vector2:
	var sum_vec: Vector2 = Vector2.ZERO
	for i in a_points.size():
		sum_vec += a_points[i]

	return sum_vec/a_points.size()