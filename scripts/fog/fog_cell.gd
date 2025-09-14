# reference: https://github.com/OneLoneCoder/Javidx9/blob/master/PixelGameEngine/SmallerProjects/OneLoneCoder_PGE_ShadowCasting2D.cpp
class_name FogCell extends Object

var exist: bool = false
var edge_ids: PackedInt32Array

var start: Vector2i = Vector2i.ZERO
var end: Vector2i = Vector2i.ZERO

func _init() -> void:
	edge_ids = PackedInt32Array()
	edge_ids.resize(4)
