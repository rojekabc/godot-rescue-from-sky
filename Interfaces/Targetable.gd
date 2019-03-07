var object

var targetters = []

func _init(object):
	self.object = object

# Remove one of the targetter
func remove(targetter):
	targetters.erase(targetter)

func add(targetter):
	targetters.append(targetter)

# Object is removed
func removed():
	for targeter in targetters:
		var moveable = targeter.get('Moveable')
		if moveable:
			moveable.move_home()