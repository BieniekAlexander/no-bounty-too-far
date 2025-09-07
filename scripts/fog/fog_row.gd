# source: https://www.albertford.com/shadowcasting/
class_name FogRow

var depth: int
var start_slope: Vector2i
var end_slope: Vector2i

func _init(a_depth: int, a_start_slope: Vector2i, a_end_slope: Vector2i) -> void:
	depth = a_depth
	start_slope = a_start_slope
	end_slope = a_end_slope
		
func tiles() -> Array[Vector2i]:
	var r_coords: Array[Vector2i] = []
	
	for col in range(
		round_ties_up(FU.product(Vector2i(self.depth, 1), self.start_slope)),
		round_ties_down(FU.product(Vector2i(self.depth, 1), self.end_slope)) + 1
	):
		r_coords.append(Vector2i(depth, col))
	
	return r_coords

func next():
	return get_script().new(
		depth + 1,
		start_slope,
		end_slope
	)

static func slope(a_tile: Vector2i) -> Vector2i:
	return Vector2i(2 * a_tile.y - 1, 2 * a_tile.x)
	
static func is_symmetric(a_row: FogRow, a_tile: Vector2i) -> bool:
	# NOTE: see original implementation in case I mess this frac stuff up: 
	return (
		FU.sum(
			Vector2i(-a_tile.y, 1),
			FU.product(a_row.start_slope, Vector2i(a_tile.x, 1))
		).x <= 0
		and FU.sum(
			Vector2i(-a_tile.y, 1),
			FU.product(a_row.end_slope, Vector2i(a_tile.x, 1))
		).x >= 0
	)
	
func round_ties_up(n: Vector2i) -> int:
	var dunno: Vector2i = FU.sum(n, Vector2i(1, 2))
	return floor(float(dunno.x)/dunno.y)

func round_ties_down(n: Vector2i) -> int:
	var dunno: Vector2i = FU.sum(n, Vector2i(-1, 2))
	return ceil(float(dunno.x)/dunno.y)
