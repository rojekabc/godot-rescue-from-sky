var object

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
		consumers = [],
		lastConsumer = null
	}

func add_consumer(resource, consumer):
	if produces.has(resource):
		var produce = produces[resource]
		produce.consumers.append(consumer)

func timeout():
	for produce in produces.values():
		_produced_resource_timeout(produce)

func _produced_resource_timeout(produce):
	if produce.has:
		_produced_resource_distribute(produce)
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
		Game.verbose(
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
	Game.verbose(
		object.get_name()
		 + " start production of " + Game.resourceDefinitions[produce.resource].name)

func _produced_resource_distribute(produce):
	for consumer in produce.consumers:
		if not consumer.Consumer.can_send(produce.resource):
			continue
		Game.verbose(
			object.get_name()
			+ " send " + Game.resourceDefinitions[produce.resource].name
			+ " to " + consumer.get_name())
		var transport = Game.getWorld().transport_start(object, consumer, produce.resource)
		produce.has = false
		consumer.Consumer.wait(produce.resource)
		break

func _init(obj):
	self.object = obj
