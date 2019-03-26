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
	
func _ready():
	pass
