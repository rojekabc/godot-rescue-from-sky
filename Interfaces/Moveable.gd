var object

var source = null
var target = null
var speed

func _init(object):
	self.object = object
	pass

func assign(source, target):
	self.source = source
	assign_target(target)

func assign_target(target):
	if self.target == target or target == null:
		return
	var hasMethod = object.has_method('target_destroyed')
	if hasMethod and (self.target != null):
		self.target.disconnect('object_destroyed', object, 'target_destroyed')
		Game.verbose(object.get_name() + ": remove target " + self.target.get_name())
	self.target = target
	if hasMethod:
		self.target.connect('object_destroyed', object, 'target_destroyed')
	Game.verbose(object.get_name() + ": set target " + self.target.get_name())

func move_home():
	assign_target(source)

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
	