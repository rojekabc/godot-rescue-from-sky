extends Node

func children_action(parent, action):
	for child in parent.get_children():
		child.call(action)

func _ready():
	pass
