class_name MU

@warning_ignore("integer_division")

static func gcd(a: int, b: int) -> int:
	if (a == 0):
		return b
	return gcd(b % a, a)

static func lcm(a: int, b: int) -> int:
	return (a * b) / gcd(a, b)
