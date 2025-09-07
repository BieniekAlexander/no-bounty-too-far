class_name IU

static func argmin(a_array: Array, a_key: Callable) -> Node:
	if a_array.size()==0:
		return null
	elif a_array.size()==1:
		return a_array[0]
	else:
		var min_value = a_key.call(a_array[0])
		var min_index = 0
		
		for i in range(1, a_array.size()):
			var val = a_key.call(a_array[i])
			
			if val < min_value:
				min_value = val
				min_index = i

		return a_array[min_index]

static func get_square_helical_indices(a_array_length: int) -> Array[Vector2i]:
	var output_index: int = 0
	var r_indices: Array[Vector2i] = []
	r_indices.resize(a_array_length**2)
	var center: Vector2i = Vector2i.ONE*(a_array_length-1)/2
	var even: int = (a_array_length+1)%2
	
	if even==0:
		r_indices[output_index] = center
		output_index+=1
	else:
		r_indices[0] = center
		r_indices[1] = center + Vector2i(0, 1)
		r_indices[2] = center + Vector2i(1, 0)
		r_indices[3] = center + Vector2i(1, 1)
		output_index += 4
	
	for layer in range(1, center.x+1): # correct
		for i in range(0, 2*layer+even):
			# clockwise
			r_indices[output_index] = Vector2i(center.x-layer+i, center.y-layer) # top-left
			r_indices[output_index+1] = Vector2i(center.x+layer+even, center.y-layer+i) #top-right
			r_indices[output_index+2] = Vector2i(center.x+layer-i+even, center.y+layer+even) #bot-right
			r_indices[output_index+3] = Vector2i(center.x-layer, center.y+layer-i+even) #bot-left
			output_index+=4
	
	return r_indices

# TODO put in test suite
#region unit tests
#for i in range(3, 9):
		#var indices: Array = get_square_helical_indices(i)
		#var vals = get_set(indices)
		#assert(indices.size()==vals.size(), "Failed for %s, %s!=%s"%[i,indices.size(),vals.size()])
	#
	## layer length checks
	##assert(get_square_helical_indices(3)=={1:2}, "3 not good")
	##assert(get_square_helical_indices(4)=={1:3}, "4 not good")
	##assert(get_square_helical_indices(5)=={1:2, 2:4}, "5 not good")
	##assert(get_square_helical_indices(6)=={1:3, 2:5}, "6 not good")
	#
	## layer count checks
	##assert(get_square_helical_indices(3)==1, "3!=1")
	##assert(get_square_helical_indices(4)==1, "4!=1")
	##assert(get_square_helical_indices(5)==2, "5!=2")
	##assert(get_square_helical_indices(6)==2, "6!=2")
	##assert(get_square_helical_indices(7)==3, "7!=3")
	##assert(get_square_helical_indices(8)==3, "8!=3")
#endregion

static func get_set(a_array: Array) -> Dictionary:
	var ret: Dictionary = {}
	for a in a_array:
		ret[a] = 0
	
	return ret

static func is_square_vec_center(a_loc: Vector2i, a_side: int) -> bool:
	var even: int = (a_side+1)%2
	var center: Vector2i = (Vector2i.ONE*(a_side-even))/2
	return (
		a_loc==center
		or a_loc==center+Vector2i(1,0)*even
		or a_loc==center+Vector2i(1,1)*even
		or a_loc==center+Vector2i(0,1)*even
	)

## returns center coordinates for square array of a given size
static func get_center_index(a_side: int) -> Vector2i:
	return Vector2i.ONE*(a_side-1)/2

## returns a potential index offset for grid searches
static func get_even_offset(a_side: int) -> int:
	return (a_side+1)%2
