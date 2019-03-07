extends Node

func _ready():
	pass

func assign(obj, destroy_func = 'destroy'):
	obj.data.hp = 100
	obj.data.destroyFunc = destroy_func

func is_destroyed(obj):
	return obj.data.hp <= 0

func hit(obj, points):
	if is_destroyed(obj):
		return
		
	# TODO: some unification
	Game.verbose('Hit ' + str(points) + ' points to ' + obj.get_name())
	if obj.data.hp > points:
		obj.data.hp -= points
	else:
		Game.verbose(obj.get_name() + ' destroyed')
		obj.data.hp = 0
		var destroyFunc = obj.data.destroyFunc
		if destroyFunc and obj.has_method(destroyFunc):
			obj.call(destroyFunc)

