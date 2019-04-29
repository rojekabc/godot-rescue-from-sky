class_name ResourceDistribution
extends Node

# --Map owner -> producers--
#      --Map resource -> structure--
# Map owner -> Map resource -> structure

# events:
#   add structure => by register
#   destroy structure => form of stop production
#   start production => event
#   stop production => event
#   change owner => event

# The list of consumers registered per structure
# It keeps only working structures, which currently has a need of consume
# Map {owner -> {Map {resource -> [structure]}}
var consumerMap = {}

# The list of resources ready to distribute
# It keeps only working structures
# Map {owner -> {Map {resource -> {List[Structure]}}
var resourceMap = {}

# structure destroyed or has been on the border
# Remove structure as consumer
# Remove structure as owner of structure
func unregister_structure(structure : Structure):
	var strDef = Game.structureDefinitions[structure.type]
	for consumeResource in strDef.consumes:
		_unregister_structure(consumerMap, consumeResource, structure)
	for produceResource in strDef.produces:
		_unregister_structure(resourceMap, produceResource, structure)
		for consumeResource in Game.resourceDefinitions[produceResource].consumes:
			_unregister_structure(consumerMap, consumeResource, structure)

# structure is new in game or start production (after change or not the owner)
func register_structure(structure : Structure):
	var strDef = Game.structureDefinitions[structure.type]
	for consumeResource in strDef.consumes:
		register_consumer(consumeResource, structure)
		structure.Consumer.add(consumeResource)
	for produceResource in strDef.produces:
		for consumeResource in Game.resourceDefinitions[produceResource].consumes:
			register_consumer(consumeResource, structure)
			structure.Consumer.add(consumeResource)

# When ready for new resource after finish production or when game starts or transports will be destroyed and should
# query for next resource
func register_consumer(resourceIdx : int, structure : Structure):
	if not send_resource_to(resourceIdx, structure):
		_register_structure(consumerMap, resourceIdx, structure)

func send_resource_to(resourceIdx : int, consumer : Structure) -> bool:
	var playerResources = resourceMap[consumer.ownerIdx]
	if playerResources.has(resourceIdx):
		var producers : Array = playerResources[resourceIdx]
		if producers.empty(): return false
		var producer = Tool.array_random(producers)
		producers.erase(producer)
		Game.getWorld().transport_start(producer, consumer, resourceIdx)
		return true
	else:
		return false

func send_resource_from(resourceIdx : int, producer : Structure) -> bool:
	var playerConsumers = consumerMap[producer.ownerIdx]
	if playerConsumers.has(resourceIdx):
		var consumers : Array = playerConsumers[resourceIdx]
		if consumers.empty(): return false
		var consumer = Tool.array_random(consumers)
		consumers.erase(consumer)
		consumer.Consumer.wait(resourceIdx)
		producer.Producer.consume(resourceIdx)
		Game.getWorld().transport_start(producer, consumer, resourceIdx)
		return true
	else:
		return false
	
func register_resource(resourceIdx : int, structure : Structure):
	if not send_resource_from(resourceIdx, structure):
		_register_structure(resourceMap, resourceIdx, structure)

func _ready():
	_create_data()

func _create_data():
	for i in range(2):
		consumerMap[i] = {}
		resourceMap[i] = {}

func _unregister_structure(map : Dictionary, resourceIdx : int, structure : Structure):
	var playerData = map[structure.ownerIdx]
	if playerData.has(resourceIdx):
		playerData[resourceIdx].erase(structure)

func _register_structure(map : Dictionary, resourceIdx : int, structure : Structure):
	var playerData = map[structure.ownerIdx]
	if playerData.has(resourceIdx):
		if not playerData[resourceIdx].has(structure):
			playerData[resourceIdx].append(structure)
	else:
		playerData[resourceIdx] = [structure]
