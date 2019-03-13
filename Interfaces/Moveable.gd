var object

var source = null
# Targetable
var target = null
var speed

func _init(object):
	self.object = object
	pass

func assign(source, target):
	self.source = source
	self.target = target
	target.Targetable.add(object)

func stop_targeting():
	var targetable = target.get('Targetable')
	if targetable:
		targetable.remove(object)
	target = null

func move_home():
	target = source
	var targetable = target.get('Targetable')
	if targetable:
		targetable.add(object)

func is_home():
	return target == source

func hit_target(points):
	target.Destructable.hit(points)

func get_target_planes():
	return target.PlaneHolder.planes

func calculate_move():
	var targetVector = target.position - object.position
	var distance = targetVector.length()
	var targetDirection = targetVector.normalized()
	var time
	var targetPosition
	if distance > speed:
		time = Game.CONFIGURATION.timertick
		targetPosition = object.position + targetDirection * speed
	# elif distance < 10:
	#	# It's very close - the action can be started
	#	pass
	else:
		time = Game.CONFIGURATION.timertick * distance / speed
		targetPosition = target.position
	return {position = targetPosition, time = time}
	