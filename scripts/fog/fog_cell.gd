# reference: https://github.com/OneLoneCoder/Javidx9/blob/master/PixelGameEngine/SmallerProjects/OneLoneCoder_PGE_ShadowCasting2D.cpp
class_name FogCell extends Object

#region obstruction fields
var bounding: bool	# whether this forms the world boundary, in which case obstructs will always be true
var obstructs: bool = false
var edge_ids: PackedInt32Array

#region location fields
## cell top left position
var tl: Vector2i

## cell top right position
var tr: Vector2i

## cell bottom left position
var bl: Vector2i

## cell bottom right position
var br: Vector2i
#endregion

func _init(a_top_left: Vector2i, a_width: int, a_bounding: bool = false) -> void:
	bounding = a_bounding
	tl = a_top_left
	tr = tl + Vector2i(1,0)*a_width
	bl = tl + Vector2i(0,1)*a_width
	br = tl + Vector2i(1,1)*a_width
	
	edge_ids = PackedInt32Array()
	edge_ids.resize(4)
