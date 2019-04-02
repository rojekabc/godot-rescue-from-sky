class_name Destructable

var object
const HP_MAX : int = 100
const HP_DESTROYED : int = 0

var hp : int = HP_MAX
var destroyFunc = 'destroy'

func _init(object):
	self.object = object

func assign(destroy_func = 'destroy'):
	destroyFunc = destroy_func

func is_destroyed():
	return hp == HP_DESTROYED

func get_hp_rate()->float:
	return float(hp)/float(HP_MAX)

func update_hp(pointsChange : int):
	set_hp(hp + pointsChange)

func set_hp(points : int):
	hp = clamp(points, HP_DESTROYED, HP_MAX)
	Game.verbose(object.get_name() + ' Set HP to ' + str(points))
	if is_destroyed() and destroyFunc and object.has_method(destroyFunc):
		object.call(destroyFunc)

func heal(points : int):
	set_hp(hp + points)

func hit(points : int):
	if is_destroyed():
		return
	set_hp(hp - points)
