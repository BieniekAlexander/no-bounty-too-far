# source: https://www.albertford.com/shadowcasting/
class_name FogQuadrant

enum CD {
	NORTH	= 0,
	EAST		= 1,
	SOUTH	= 2,
	WEST		= 3
}

var cardinal: CD
var origin: Vector2i

func _init(a_cardinal: CD, a_origin: Vector2i) -> void:
	cardinal = a_cardinal
	origin = a_origin
	
	
func transform(a_coords: Vector2i) -> Vector2i:
	if self.cardinal == CD.NORTH:
		return Vector2i(origin.x+a_coords.y, origin.y-a_coords.x)
	if self.cardinal == CD.SOUTH:
		return Vector2i(origin.x+a_coords.y, origin.y+a_coords.x)
	if self.cardinal == CD.EAST:
		return Vector2i(origin.x+a_coords.x, origin.y+a_coords.y)
	else: # self.cardinal == self.west
		return Vector2i(origin.x-a_coords.x, origin.y+a_coords.y)
