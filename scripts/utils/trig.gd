class_name TU

const cardinal_vectors: Array[Vector2i] = [
	Vector2i.RIGHT,
	Vector2i.RIGHT+Vector2i.DOWN,
	Vector2i.DOWN,
	Vector2i.DOWN+Vector2i.LEFT,
	Vector2i.LEFT,
	Vector2i.LEFT+Vector2i.UP,
	Vector2i.UP,
	Vector2i.UP+Vector2i.RIGHT
]

static func get_closest_vector_to_angle(a_angle: float, a_vectors: Array[Vector2i]) -> Vector2i:
	var min_angle: float = INF
	var min_vec: Vector2 = a_vectors[0]
	var target_vec: Vector2 = Vector2.from_angle(a_angle)
	
	for vec in a_vectors:
		var this_angle: float = abs(target_vec.angle_to(vec))
		
		if min_angle > this_angle:
			min_angle = this_angle
			min_vec = vec
			
	return Vector2i(min_vec)

static func get_adjacent_cell_offset(a_angle: float) -> Vector2i:
	return Vector2i(
		-get_closest_vector_to_angle(
			a_angle,
			cardinal_vectors
		)
	)

## 2D Array indicating, for each cell, the indices pointing towards the center of the array
static func get_center_offset_array(a_side: int) -> Array:
	# TODO probably not done
	var center: Vector2i = Vector2i.ONE*(a_side-1)/2
	var r_array: Array[Array] = []
	r_array.resize(a_side)
	
	for i in range(a_side):
		r_array[i] = []
		r_array[i].resize(a_side)
		
		for j in range(a_side):
			var loc: Vector2i = Vector2i(i, j)
			
			if IU.is_square_vec_center(loc, a_side):
				r_array[i][j] = Vector2i.ZERO
			else:
				r_array[i][j] = TU.get_adjacent_cell_offset(
					Vector2(loc-center).angle()
				)
	
	return r_array
