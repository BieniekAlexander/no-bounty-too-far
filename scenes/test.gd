@tool
extends Node

@export var side: int = 5:
	set(value): side = value
@export var run_button:bool:
	set(value):
		if Engine.is_editor_hint():
			_run()

func _run() -> void:
	var side: int = side
	var offsets: Array = TU.get_center_offset_array(side)
	
	# testing offset array traversal
	var space: Array[Array] = []
	for i in range(side):
		space.append([])
		for j in range(side):
			space[i].append(0)
	
	# simulating obstructions
	space[2][2] = -1
	space[2][3] = -1
	space[3][3] = 1
	space[3][4] = 1
	space[4][3] = 1
	space[4][4] = 1
	
	for loc in IU.get_square_helical_indices(side):
		var offset: Vector2i = offsets[loc.x][loc.y]
		var towards: Vector2i = loc+offset
		
		if (
			space[towards.x][towards.y]==1
			and space[loc.x][loc.y]!=-1
		):
			space[loc.x][loc.y]=1
	
	for row in space: print(row)
	
