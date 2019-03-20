extends Node

func children_action(parent, action):
	for child in parent.get_children():
		child.call(action)

func array_random(array : Array):
	return array[randi() % array.size()]

func _ready():
	pass
