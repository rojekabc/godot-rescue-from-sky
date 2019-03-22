var object

var hp = 100
var destroyFunc = 'destroy'

func _init(object):
	self.object = object

func assign(destroy_func = 'destroy'):
	destroyFunc = destroy_func

func is_destroyed():
	return hp <= 0

func get_hp_rate()->float:
	return hp/100.0

func hit(points):
	if is_destroyed():
		return
		
	if hp > points:
		Game.verbose('Hit ' + str(points) + ' points to ' + object.get_name())
		hp -= points
	else:
		Game.verbose('Hit ' + str(points) + ' points to ' + object.get_name() + ' and destroyed')
		hp = 0
		if destroyFunc and object.has_method(destroyFunc):
			object.call(destroyFunc)
