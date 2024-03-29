class_name Consumer
var object

var consumes = {}

func _init(obj):
	self.object = obj

# list consumed resources
func list():
	return consumes.keys()

func add(resource):
	if consumes.has(resource):
		return
	consumes[resource] = {
		resource = resource,
		has = false,
		supplier = null,
		# transport start, waiting for resource
		wait = false
	}

func has(resource):
	return consumes[resource].has

func put(resource):
	var consumedResource = consumes[resource]
	consumedResource.has = true
	consumedResource.wait = false

func wait(resource):
	var consumedResource = consumes[resource]
	consumedResource.wait = true

func consume(resource):
	clear(resource)
	Game.getWorld().getResourceDistribution().register_consumer(resource, object)

	
func clear(resource):
	var consumedResource = consumes[resource]
	consumedResource.has = false
	consumedResource.wait = false

func can_send(resource) -> bool:
	var consumedResource = consumes[resource]
	return not (consumedResource.has or consumedResource.wait or object.Destructable.is_destroyed())

