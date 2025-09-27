## Extension of a NavigationRegion 2D, supplying additional information regarding what an agent should patrol, 
## as composed of [PatrolPolygon]
class_name PatrolRegion2D extends NavigationRegion2D

var polygon_graph: Dictionary = {}

func _ready() -> void:
	for i in range(navigation_polygon.get_polygon_count()):
		var bound_locations: PackedVector2Array = PackedVector2Array(
			Array(
				navigation_polygon.get_polygon(i)
			).map(
				func(index: int): return navigation_polygon.get_vertices()[index]	
			)
		)

		polygon_graph[i] = PatrolPolygon.new(
			Set.new(navigation_polygon.get_polygon(i)),
			bound_locations
		)
		
	for x in polygon_graph.values():
		for y in polygon_graph.values():
			if x==y: continue
			if x.is_connected_to(y):
				x.neighbors.add(y)
				y.neighbors.add(x)

func get_closest_polygon(a_point: Vector2) -> PatrolPolygon:
	# TODO find a more performant way to do this, maybe BST or something
	var min_distance: float = INF
	var closest_polygon: PatrolPolygon = null

	for polygon: PatrolPolygon in polygon_graph.values():
		if polygon.contains_point(a_point):
			return polygon
		else:
			var distance = range(polygon.bound_locations.size()).map(
				func(i: int):
					var closest_point: Vector2 = Geometry2D.get_closest_point_to_segment(
						polygon.bound_locations[i],
						polygon.bound_locations[i+1 if i+1<polygon.bound_locations.size() else 0],
						a_point
					)
					return closest_point.distance_squared_to(a_point)
			).min()

			if distance < min_distance or closest_polygon==null:
				min_distance = distance
				closest_polygon = polygon

	return closest_polygon

func _physics_process(_delta: float) -> void:
	for polygon: PatrolPolygon in polygon_graph.values():
		polygon.staleness += .1
