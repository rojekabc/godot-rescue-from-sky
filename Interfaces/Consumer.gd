var object

var consumes = {}

func _init(obj):
	self.object = obj

# list consumed resources
func list():
	return consumes.keys()

func set_suplier(resource, suplier):
	consumes[resource].suplier = suplier
	
func add(resource):
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
	
func clear(resource):
	var consumedResource = consumes[resource]
	consumedResource.has = false
	consumedResource.wait = false

func can_send(resource):	
	var consumedResource = consumes[resource]
	return not (consumedResource.has or consumedResource.wait)

