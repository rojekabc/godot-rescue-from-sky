extends Node2D
class_name GameWorld

var selectTarget = null
var ownerMap : OwnerMap

func _ready():
	# Enable randomization
	randomize()
	# Hide templates
	Tool.children_action($Map/UI, 'hide')
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
	pass

func _status(msg):
	$Map/UI/Status.status(msg)
	
func _info(msg):
	$Map/UI/Status.info(msg)
	
func _fail(msg):
	$Map/UI/Status.fail(msg)
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		if selectTarget:
			_select_target_action(event.global_position)
		elif $Map/UI/Suqad.visible:
			return
		else:
			var strPressed = _find_structure_at(event.global_position)
			if strPressed:
				strPressed.pressed(self)
				return
	pass

func _select_target_action(globalPosition):
	var target = _find_element_at(globalPosition)
	if target == null:
		return _fail('Nothing selected')
	if target.is_in_group('Structure'):
		if target == selectTarget.source:
			return _fail('Cannot select itself')
		if target.ownerIdx == selectTarget.source.ownerIdx:
			if target.type == Game.AIRPORT:
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
	var selected = null
	var results = get_world_2d().direct_space_state.intersect_point(globalPosition, 4, [], collisionMask, true, true)
	if results:
		for result in results:
			return result.collider
	return null

func _find_structure_at(global_position):
	for structure in $Map/Structures.get_children():
		var rect = Rect2(
			structure.global_position.x-structure.HALF_SIZE, structure.global_position.y-structure.HALF_SIZE,
			structure.FULL_SIZE, structure.FULL_SIZE)
		if rect.has_point(global_position):
			return structure;
	return null

func _find_structures_at(global_positions):
	var result = []
	for pos in global_positions:
		var structure = _find_structure_at(pos)
		if structure:
			result.append(structure)
	return result

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
	
	for ownerIdx in range(2):
		for strType in Game.STRUCTURE.values():
			var structure = _structure_create(ownerIdx, strType)
			if structure.type == Game.STRUCTURE.AIRPORT:
				structure.PlaneHolder.add_plane(_airplane_create(ownerIdx, Game.PLANE.FIGHTER))
				structure.PlaneHolder.add_plane(_airplane_create(ownerIdx, Game.PLANE.BOMBER))
			while not _find_structures_at(structure.get_corners()).empty():
				Game.verbose('Fix structure collision')
				structure.random_position(ownerIdx, $Map/OwnerMap)
			$Map/Structures.add_child(structure)
	_create_resource_network()

# Create consumer-suplier network
func _create_resource_network():
	for structure in $Map/Structures.get_children():
		for consume in structure.Consumer.list():
			var suppliers = _find_producers_of(structure.ownerIdx, consume)
			var supplier = _find_best_supplier(structure, suppliers)
			if supplier:
				structure.set_suplier(consume, supplier)
				supplier.register_consumer(consume, structure)

func _find_best_supplier(structure, suppliers):
	if (suppliers == null) or suppliers.empty():
		return null
	var bestSuplierDistance = 1000000
	var bestSupplierIdx = -1
	var suplierIdx = 0
	for suplier in suppliers:
		var distance = (structure.position - suplier.position).length()
		if distance < bestSuplierDistance:
			bestSuplierDistance = distance
			bestSupplierIdx = suplierIdx
		suplierIdx += 1
	return suppliers[bestSupplierIdx]

func _find_producers_of(ownerIdx, resource):
	var result = []
	for structure in $Map/Structures.get_children():
		if structure.ownerIdx != ownerIdx:
			continue
		if structure.Producer.is_producing(resource):
			result.append(structure)
	return result

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
	var panel = $Map/UI/Suqad
	panel.set_airport(airport)
	_fix_panel_position(panel, airport.position)
	pass

func squad_start(source, target, planes):
	var squad = Game.Squad.duplicate()
	squad.collision_layer = Game.SQUAD_COLLISION_LAYER
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
	var time = distance/Game.CONFIGURATION.transportSpeed*$Timer.wait_time
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
		_calculate_move_tween(object)
		object.reset_rotation()
	elif object.is_in_group("Army"):
		$Tween.remove(object, key)
		var target = object.get_target()
		target.change_power(object.ownerIdx, Game.CONFIGURATION.armyPower * object.get_hp_rate())
		object.destroy()
	pass

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
	