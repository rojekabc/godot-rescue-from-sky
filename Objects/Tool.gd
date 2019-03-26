extends Node

func children_action(parent, action):
	for child in parent.get_children():
		child.call(action)

func array_random(array : Array):
	return array[randi() % array.size()]

func array_max(array : PoolRealArray) -> float:
	var result : float = array[0]
	for value in array:
		result = max(value, result)
	return result
	
func array_min(array : PoolRealArray) -> float:
	var result : float = array[0]
	for value in array:
		result = min(value, result)
	return result

func array_max_idx(array : PoolRealArray) -> int:
	var result : int = 0
	var found = array[result]
	for idx in range(0, array.size()):
		if array[idx] > found:
			result = idx
			found = array[idx]
	return result
	
func array_min_idx(array : PoolRealArray) -> int:
	var result : int = 0
	var found = array[result]
	for idx in range(0, array.size()):
		if array[idx] < found:
			result = idx
			found = array[idx]
	return result

func array_min_max_idx(array : PoolRealArray) -> PoolIntArray:
	var idxmin : int = 0
	var idxmax : int = 0
	var foundmin = array[idxmin]
	var foundmax = array[idxmax]
	for idx in range(0, array.size()):
		if array[idx] > foundmax:
			idxmax = idx
			foundmax = array[idx]
		if array[idx] < foundmin:
			idxmin = idx
			foundmin = array[idx]
	return PoolIntArray([idxmin, idxmax])
	
func _ready():
	pass
