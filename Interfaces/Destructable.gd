var object

var hp
var destroyFunc

func _init(object):
	self.object = object
	self.hp = 100

func assign(destroy_func = 'destroy'):
	destroyFunc = destroy_func

func is_destroyed():
	return hp <= 0

func hit(points):
	if is_destroyed():
		return
		
	Game.verbose('Hit ' + str(points) + ' points to ' + object.get_name())
	if hp > points:
		hp -= points
	else:
		Game.verbose(object.get_name() + ' destroyed')
		hp = 0
		if destroyFunc and object.has_method(destroyFunc):
			object.call(destroyFunc)
