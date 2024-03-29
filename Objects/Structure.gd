extends Area2D
class_name Structure

const HALF_SIZE = 30
const FULL_SIZE = 60
var objectType : int = Game.OBJECT_STRUCTURE

# type of Game.STRUCTURE enum
var type
var ownerIdx
var mapPosition : Vector2

var Destructable : Destructable
var Consumer
var Producer

var LOG = Game.CONFIGURATION.loggers.has('Structure')

signal object_destroyed(object)
signal owner_changed

func destroy():
	emit_signal('object_destroyed', self)

# callback function
func change_health(prevHp : int, curHp : int):
	# check state is changed (produce, not produce)
	var prevProduce : bool = float(prevHp)/float(Destructable.HP_MAX) >= 0.5
	var curProduce : bool = float(curHp)/float(Destructable.HP_MAX) >= 0.5
	if prevProduce != curProduce:
		if curProduce:
			Game.verbose(get_name() + ' produce enable')
			Game.getWorld().getResourceDistribution().register_structure(self)
		else:
			Game.verbose(get_name() + ' produce disable')
			Game.getWorld().getResourceDistribution().unregister_structure(self)

func _init():
	Destructable = Game.Destructable.new(self)
	Consumer = Game.Consumer.new(self)
	Producer = Game.Producer.new(self)

func target_destroyed(target):
	Game.verbose(get_name() + ': Target destroyed')

# Register consumer, which will receive produced resource
func register_consumer(resource, consumer):
	Producer.add_consumer(resource, consumer)

func set_suplier(resource, suplier):
	Consumer.set_suplier(resource, suplier)

func random_position(ownerIdx : int, ownerMap : OwnerMap):
	# random position on the map
	mapPosition.x = (ownerMap.WIDTH/2) * ownerIdx + randi() % ((ownerMap.WIDTH-1)/2)
	mapPosition.y = randi() % (ownerMap.HEIGHT-1)
	# position.x = (ownerMap.WIDTH/2) * ownerIdx + randi() % ((ownerMap.WIDTH-1)/2)
	# position.y = randi() % (ownerMap.HEIGHT-1)
	# fit position to pixel map
	position.x = mapPosition.x * ownerMap.PIXEL_WIDTH
	position.y = mapPosition.y * ownerMap.PIXEL_HEIGHT
	# shift to center
	position.x += HALF_SIZE
	position.y += HALF_SIZE
	pass

func setup(type, ownerIdx, timer) -> Structure:
	self.type = type
	self.ownerIdx = ownerIdx
	assign_type(type, timer)
	assign_owner(ownerIdx)
	timer.connect('timeout', self, '_timeout')
	return self

func assign_owner(ownerIdx):
	self.ownerIdx = ownerIdx
	$Sprite.material = Game.playerDefinitions[ownerIdx].armyMaterial

func assign_type(strType, timer):
	var strDef = Game.structureDefinitions[strType]
	type = strDef.type
	$Acronym.text = ''
	match type:
		Game.STRUCTURE.AIRPORT: $Sprite.texture = load('res://Resources/StructureAirport.png')
		Game.STRUCTURE.CITY: $Sprite.texture = load('res://Resources/StructureCity.png')
		Game.STRUCTURE.VILLAGE: $Sprite.texture = load('res://Resources/StructureVillage.png')
		Game.STRUCTURE.BUNKER: $Sprite.texture = load('res://Resources/StructureFort.png')
		Game.STRUCTURE.FACTORY: $Sprite.texture = load('res://Resources/Factory.png')
		Game.STRUCTURE.CAPITAL: $Sprite.texture = load('res://Resources/StructureHQ.png')
	for resource in strDef.consumes:
		Consumer.add(resource)
	for resource in strDef.produces:
		Producer.add_resource(resource)
	_call_type_function('create_data')

func get_type():
	return type

func get_name():
	return Game.playerDefinitions[ownerIdx].name + '.' + Game.structureDefinitions[type].name

func get_info():
	return Game.playerDefinitions[ownerIdx].name + ' ' + Game.structureDefinitions[type].name + ' [' + Destructable.get_info() + ']'
	
func _ready():
	if get_parent().get_name() == 'Templates':
		return
	pass

func get_corners() -> PoolVector2Array:
	var result : PoolVector2Array
	result.append(Vector2(position.x-HALF_SIZE, position.y-HALF_SIZE))
	result.append(Vector2(position.x-HALF_SIZE, position.y+HALF_SIZE))
	result.append(Vector2(position.x+HALF_SIZE, position.y-HALF_SIZE))
	result.append(Vector2(position.x+HALF_SIZE, position.y+HALF_SIZE))
	return result

func update_owner(ownerMap : OwnerMap):
	var keep = 0
	if ownerMap.get_at(mapPosition) == self.ownerIdx: keep += 1
	if ownerMap.get_at(Vector2(mapPosition.x + 1, mapPosition.y)) == self.ownerIdx: keep += 1
	if ownerMap.get_at(Vector2(mapPosition.x, mapPosition.y + 1)) == self.ownerIdx: keep += 1
	if ownerMap.get_at(Vector2(mapPosition.x + 1, mapPosition.y + 1)) == self.ownerIdx: keep += 1
	match keep:
		0:
			# Change owner - first assign owner, after set HP structure will be registered as a consumer
			assign_owner((ownerIdx + 1) % 2)
			Destructable.update_hp(+20) # quick rebuild by army
			# TODO start repair
			emit_signal('owner_changed')
		1, 2, 3:
			# Do some destruction - moving front
			if Destructable.get_hp_rate() > 0.1:
				Destructable.update_hp(-30)
		4:
			# TODO start repair - now fully repair
			Destructable.update_hp(+20) # quick rebuild by army
	pass

func _call_type_function(function, args=null):
	var strName = Game.structureDefinitions[type].name
	var callName = '_' + strName + '_' + function
	if has_method(callName):
		if args: call(callName, args)
		else: call(callName)

func pressed(world):
	_call_type_function('pressed', world)
	pass

func _timeout():
	Producer.timeout()
	_call_type_function('timeout')
	pass

func _Capital_timeout():
	_Bunker_timeout()


func _Bunker_timeout():
	if not Producer.has(Game.RESOURCE.ARMY):
		return
	var target = Game.getWorld().army_find_target(self)
	if target:
		Game.getWorld().army_start(self, target)
		Producer.consume(Game.RESOURCE.ARMY)
	pass

func _Airport_timeout():
	if not Consumer.has(Game.RESOURCE.AIRPLANE):
		return
	var count : Dictionary = Game.getPlaneManager().count_assigned_planes(self)
	var sum : int = 0
	var limitSum : int = 0
	for type in Game.PLANE.values():
		sum += count[type]
		limitSum += Game.CONFIGURATION.airportLimit[type]
	if sum >= limitSum:
		return
	var rand : float = randf()
	var randLimit : float = 0.0
	for type in Game.PLANE.values():
		var planeLimit = Game.CONFIGURATION.airportLimit[type]
		randLimit += float(planeLimit-count[type])/float(limitSum-sum)
		if rand <= randLimit:
			Game.getPlaneManager().create_plane(ownerIdx, type, self)
			Consumer.consume(Game.RESOURCE.AIRPLANE)
			return

func _Airport_pressed(world):
	world.ui_squad_panel(self)