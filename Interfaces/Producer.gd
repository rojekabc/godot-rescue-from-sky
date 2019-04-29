var LOG = Game.CONFIGURATION.loggers.has('Producer')

var object : Structure

var produces = {}

func is_producing(resource):
	return produces.has(resource)

func has(resource):
	return produces[resource].has

func consume(resource):
	var produce = produces[resource]
	if produce.has:
		produce.has = false

func add_resource(resource):
	var resourceDefinition = Game.resourceDefinitions[resource]
	produces[resource] = {
		resource = resource,
		producing = false,
		has = false,
		timeout = resourceDefinition.timeout,
	}

func timeout():
	if object.Destructable.is_destroyed():
		return
	for produce in produces.values():
		_produced_resource_timeout(produce)

func _produced_resource_timeout(produce):
	if produce.has:
		Game.getWorld().getResourceDistribution().register_resource(produce.resource, object)
	elif produce.producing:
		_produced_resource_produce_tick(produce)
	elif _produced_resource_has_resources(produce):
		_produced_resource_start_production(produce)
	pass


func _produced_resource_produce_tick(produce):
	produce.timeout -= 1
	if produce.timeout == 0:
		produce.has = true
		produce.producing = false
		if LOG: Game.verbose(
			object.get_name()
			+ " produced " + Game.resourceDefinitions[produce.resource].name)
	pass
	
# check that has resources to start produce
func _produced_resource_has_resources(produce):
	var result = true
	var resDef = Game.resourceDefinitions[produce.resource]
	for consumedResource in resDef.consumes:
		if not object.Consumer.has(consumedResource):
			result = false
	return result

func _produced_resource_start_production(produce):
	# consume resources
	var resDef = Game.resourceDefinitions[produce.resource]
	for consumedResource in resDef.consumes:
		object.Consumer.consume(consumedResource)
	# start produce
	produce.producing = true
	produce.timeout = resDef.timeout
	if LOG: Game.verbose(
		object.get_name()
		 + " start production of " + Game.resourceDefinitions[produce.resource].name)

func _init(obj):
	self.object = obj
