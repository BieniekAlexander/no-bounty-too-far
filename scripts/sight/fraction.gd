## Class representing a rational fraction
class_name FU

static func reduced(a_pair: Vector2i) -> Vector2i:
	var d: int = MU.gcd(a_pair.x, a_pair.y)
	return Vector2i(a_pair.x / d, a_pair.y / d)

static func as_decimal(a_pair: Vector2i) -> float:
	return float(a_pair.x)/a_pair.y

static func product(a: Vector2i, b: Vector2i) -> Vector2i:
	return Vector2i(
		a.x*b.x,
		a.y*b.y
	)

static func sum(a: Vector2i, b: Vector2i) -> Vector2i:
	var lcm: int = MU.lcm(a.y, b.y)
	return Vector2i(
		get_scale(a, lcm)*a.x + get_scale(b, lcm)*b.x,
		lcm
	)

## Get the multiple that puts the fraction at the desired denominator
static func get_scale(a_pair: Vector2i, a_denominator: int) -> int:
	return a_denominator / a_pair.y
