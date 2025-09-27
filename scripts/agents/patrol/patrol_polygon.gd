## A representation of a region to patrol, as described by [url=https://arxiv.org/html/2508.18527v1]Composite Potential Fields[/url]
class_name PatrolPolygon

var neighbors: Set
var vertex_indices: Set
var bound_locations: PackedVector2Array
var centroid: Vector2

## A measure that increases according to situations worth investigating based on an agent's perceptions,
##  e.g. if an agent spots an unknown person or an out-of-place item
var suspicion: float = 0.0

## A measure of how long it's been since the area was patrolled
var staleness: float = 0.0

## A measure of how accessible a given region is from other regions, 
var connectivity: float = 0.0

func _init(
	a_vertex_indices: Set,
	a_bound_locations: PackedVector2Array,
	a_neighbors: Set = Set.new()
) -> void:
	neighbors = a_neighbors
	bound_locations = a_bound_locations
	vertex_indices = a_vertex_indices
	centroid = get_centroid(bound_locations)

func get_interest() -> float:
	return suspicion + staleness + connectivity

func is_connected_to(a_other: PatrolPolygon) -> bool:
	return vertex_indices.intersection(a_other.vertex_indices).size()>=2

func contains_point(a_point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(a_point, bound_locations)

static func get_centroid(a_points: PackedVector2Array) -> Vector2:
	var sum_vec: Vector2 = Vector2.ZERO
	for i in a_points.size():
		sum_vec += a_points[i]

	return sum_vec/a_points.size()