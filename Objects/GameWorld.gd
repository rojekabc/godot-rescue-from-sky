extends Node2D
class_name GameWorld

var selectTarget = null
var ownerMap : OwnerMap

var CLICKLOG = Game.CONFIGURATION.loggers.has('ClickLog')

func _ready():
	# Enable randomization
	randomize()
	# Hide templates
	Tool.children_action($UI, 'hide')
	# Start timestamp calculation from beginig of play
	$Timer.wait_time = Game.CONFIGURATION.timertick
	$Timer.connect('timeout', self, "_timeout")
	# Prepare materials
	_prepare_materials()
	# Crate real map
	ownerMap = load('res://Objects/OwnerMap.gd').new()
	_map_create()
	# Start all transport moves with monitoring them
	$Tween.start()
	$Tween.connect('tween_completed', self, '_tween_completed')
	# Enable mouse press processing
	set_process_input( true )
	
	$Map/RuleOfWin.start_rule_take_capital($Map/Structures)
	pass

func _status(msg):
	$UI/Status.status(msg)
	
func _info(msg):
	$UI/Status.info(msg)
	
func _fail(msg):
	$UI/Status.fail(msg)
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		mouse_pressed_at(event.global_position)

func mouse_pressed_at(globalPosition : Vector2) -> void:
	var elements : Array = find_elements_at(globalPosition)
	if CLICKLOG: log_information(elements)
	
	if selectTarget:
		print_status(elements)
		_select_target_action(elements)
	elif $UI/Suqad.visible:
		return
	else:
		print_status(elements)
		press_structure(elements)

func press_structure(elements):
	for element in elements:
		if not element.is_in_group('Structure'):
			continue
		var structure : Structure = element
		if structure && Game.playerDefinitions[structure.ownerIdx].type == Player.PlayerType.HUMAN_PLAYER:
			structure.pressed(self)

func print_status(elements : Array):
	for element in elements:
		_info(element.get_info())

func log_information(elements : Array) -> void:
	for element in elements:
		if element.has_method('toString'):
			Game.verbose(element.toString())
		else:
			Game.verbose(str(element))

func _select_target_action(elements : Array):
	if elements.empty():
		return _fail('Nothing selected')
	var target : Area2D = elements[0] as Area2D
	if target.is_in_group('Structure'):
		if target == selectTarget.source:
			return _fail('Cannot select itself')
		if target.ownerIdx == selectTarget.source.ownerIdx:
			if target.type == Game.STRUCTURE.AIRPORT:
				_info('Planned move to ' + target.get_name())
			else:
				return _fail('Unknown mission against your structure')
		else:
			_info('Planned bombarding of ' + target.get_name())
	elif target.is_in_group('Transport'):
		if target.ownerIdx == selectTarget.source.ownerIdx:
			return _fail('Unknown mission against your transport')
		else:
			_info('Planned bombarding of ' + target.get_name())
	elif target.is_in_group('Squad'):
		if target.ownerIdx == selectTarget.source.ownerIdx:
			return _fail('Unknown mission against your squad')
		else:
			_info('Planned attack on ' + target.get_name())
	elif target.is_in_group('Border'):
		_info('Planned attack on ' + target.get_name())
	else:
		return _fail('Unknown mission')
	selectTarget.target = target
	squad_start(selectTarget.source, target, selectTarget.planes)
	selectTarget = null

# Find element under point. From the list the structure will be always selected as more priority.
# If nothing from possible elements (Structure, Transport) return null
func _find_element_at(globalPosition, collisionMask = Game.ALL_COLLISION_MASK) -> Area2D:
	var elements : Array = find_elements_at(globalPosition, collisionMask)
	if elements.empty():
		return null
	return elements[0]

func find_elements_at(globalPosition : Vector2, collisionMask : int = Game.ALL_COLLISION_MASK) -> Array:
	var elements : Array = []
	var results = get_world_2d().direct_space_state.intersect_point(globalPosition, 4, [], collisionMask, true, true)
	if results:
		for result in results:
			elements.append(result.collider)
	return elements

func find_elements_at_points(globalPositions : PoolVector2Array, collisionMask : int = Game.ALL_COLLISION_MASK) -> Array:
	var elements : Array = []
	for position in globalPositions:
		Tool.array_appendAll(elements, find_elements_at(position, collisionMask))
	return  elements

func _prepare_materials():
	Game.neutralMaterial = Game.Border.get_node('Sprite').material
	for playerDefinition in Game.playerDefinitions:
		playerDefinition.structureMaterial = Game.Structure.get_node('Sprite').material.duplicate()
		playerDefinition.structureMaterial.set('shader_param/color', playerDefinition.color)
		playerDefinition.armyMaterial = Game.Army.get_node('Sprite').material.duplicate()
		playerDefinition.armyMaterial.set('shader_param/color', playerDefinition.color)
		playerDefinition.transportMaterial = Game.Transport.get_node('Sprite').material.duplicate()
		playerDefinition.transportMaterial.set('shader_param/color', playerDefinition.color)

func _timeout():
	Game.timetick += 1

# Create map
# Don't allow to cross other structure on the map
func _map_create():
	ownerMap.place_borders($Map/Borders)
	
	for ownerIdx in range(Game.playerDefinitions.size()):
		var player : Player = Game.playerDefinitions[ownerIdx]
		for strType in Game.STRUCTURE.values():
			var structure = _structure_create(ownerIdx, strType)
			if structure.type == Game.STRUCTURE.AIRPORT:
				structure.PlaneHolder.add_plane(_airplane_create(ownerIdx, Game.PLANE.FIGHTER))
				structure.PlaneHolder.add_plane(_airplane_create(ownerIdx, Game.PLANE.BOMBER))
			while not find_elements_at_points(structure.get_corners(), Game.STRUCTURE_COLLISION_LAYER).empty():
				Game.verbose('Fix structure collision')
				structure.random_position(ownerIdx, $Map/OwnerMap)
			$Map/Structures.add_child(structure)
			$Map/ResourceDistribution.register_structure(structure)

func _fix_panel_position(panel, callerPosition):
	# positioning
	var margin = 10
	var uiWidth = panel.rect_size.x
	if callerPosition.x < Game.MAP_WIDTH/2:
		panel.rect_position = Vector2(Game.MAP_WIDTH - uiWidth - margin, margin)
	else:
		panel.rect_position = Vector2(margin, margin)

func select_target(airport, planes):
	selectTarget = {
		source = airport,
		planes = planes
	}
	_status('Select target')
	pass

func ui_squad_panel(airport):
	var panel = $UI/Suqad
	panel.set_airport(airport)
	_fix_panel_position(panel, airport.position)
	pass

func squad_start(source, target, planes):
	var squad = Game.Squad.duplicate()
	squad.collision_layer = Game.SQUAD_COLLISION_LAYER
	squad.collision_mask = Game.SQUAD_COLLISION_LAYER | Game.TRANSPORT_COLLISION_LAYER # detect moveable squads/transports
	squad.visible = true
	squad.position = source.position
	squad.ownerIdx = source.ownerIdx
	squad.Moveable.assign(source, target)
	squad.assign_target(target)
	squad.get_node('Sprite').material = Game.playerDefinitions[squad.ownerIdx].armyMaterial
	source.PlaneHolder.rem_planes(planes)
	squad.PlaneHolder.add_planes(planes)
	$Map/Squads.add_child(squad)
	_calculate_move_tween(squad)

func _calculate_move_tween(moveObject):
	var move = moveObject.Moveable.calculate_move()
	$Tween.interpolate_property(moveObject, "position",
		moveObject.position, move.position,
		move.time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	pass

func _calculate_full_move_tween(moveObject):
	var distance = (moveObject.Moveable.target.position - moveObject.position).length()
	var time = distance/moveObject.Moveable.speed*$Timer.wait_time
	$Tween.interpolate_property(
		moveObject, "position",
		moveObject.position, moveObject.Moveable.target.position,
		time,
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	$Tween.start()
	pass

# Call by tween signal
func _tween_completed(object, key):
	if object.is_in_group("Transport"):
		object.complete()
		# $Tween.remove(object, key)
	elif object.is_in_group("Squad"):
		$Tween.remove(object, key)
		if object.position == object.Moveable.target.position:
			object.catch_target()
		else:
			object.follow_target()
	elif object.is_in_group("Army"):
		$Tween.remove(object, key)
		var target = object.get_target()
		target.change_power(object.ownerIdx, Game.CONFIGURATION.armyPower * object.get_hp_rate())
		object.destroy()
	pass

func getResourceDistribution() -> ResourceDistribution:
	return $Map/ResourceDistribution as ResourceDistribution

func transport_start(sourceStructure, targetStructure, transportedResource):
	var transport = _transport_create(sourceStructure, targetStructure, transportedResource)
	transport.Moveable.speed = Game.CONFIGURATION.transportSpeed
	if sourceStructure == targetStructure:
		transport.complete()
		return
	transport.visible = true
	transport.position = sourceStructure.position
	$Map/Transports.add_child(transport)
	_calculate_full_move_tween(transport)
	if sourceStructure.LOG: Game.verbose(
		sourceStructure.get_name()
		+ " send " + Game.resourceDefinitions[transportedResource].name
		+ " to " + targetStructure.get_name())

func _transport_create(sourceStructure, targetStructure, transportedResource):
	var transport : Area2D = Game.Transport.duplicate()
	transport.collision_layer = Game.TRANSPORT_COLLISION_LAYER
	transport.setup(sourceStructure, targetStructure, transportedResource)
	return transport

func _structure_create(ownerIdx, type):
	var structure : Structure = Game.Structure.duplicate().setup(type, ownerIdx, $Timer)
	structure.collision_layer = Game.STRUCTURE_COLLISION_LAYER
	structure.visible = true
	structure.random_position(ownerIdx, $Map/OwnerMap)
	return structure

func _airplane_create(ownerIdx, type):
	var airplane = Game.AirPlane.new(ownerIdx, type)
	return airplane

func army_find_target_from_array(source, array, excluded=[]):
	var target = null
	var distance = 20000
	for child in array:
		if excluded.has(child):
			continue
		var targetDistance = (child.position - source.position).length()
		if targetDistance < distance:
			target = child
			distance = targetDistance
	return target

func army_find_target(source, excluded = []):
	var closest_board = army_find_target_from_array(source, $Map/Borders.get_children(), excluded)
	return closest_board

func army_create(source, target):
	var army : Area2D = Game.create(Game.Army)
	army.collision_layer = Game.ARMY_COLLISION_LAYER
	army.id = Game.get_army_id()
	army.ownerIdx = source.ownerIdx
	army.Moveable.assign(source, target)
	army.Moveable.speed = Game.CONFIGURATION.transportSpeed
	army.get_node('Sprite').material = Game.playerDefinitions[army.ownerIdx].armyMaterial
	return army

func army_start(source, target):
	var army = army_create(source, target)
	if army.LOG: Game.verbose('Send ' + army.get_name() + ' to attack ' + target.get_name())
	army.visible = true
	army.position = source.position
	army.assign_target(target)
	$Map/Armies.add_child(army)
	_calculate_full_move_tween(army)
	