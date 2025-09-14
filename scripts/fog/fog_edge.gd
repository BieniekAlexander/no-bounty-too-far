# reference: https://github.com/OneLoneCoder/Javidx9/blob/master/PixelGameEngine/SmallerProjects/OneLoneCoder_PGE_ShadowCasting2D.cpp
## A line segment representing a vision boundary
class_name FogEdge extends Object

var start: Vector2
var end: Vector2

func _init(a_start: Vector2, a_end: Vector2) -> void:
	start = a_start
	end = a_end

func _to_string() -> String:
	return "Edge: %s -> %s" % [start, end]
