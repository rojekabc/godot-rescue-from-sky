class_name Squad
extends Area2D

var LOG = Game.CONFIGURATION.loggers.has('Squad')
var objectType : int = Game.OBJECT_SQUAD

var ownerIdx
var type

var Moveable

signal object_destroyed(object)

func _ready():
	if get_parent().get_name() == 'Templates':
		return
	# structures
	connect('body_entered', self, '_body_entered')
	# transorts
	connect('area_entered', self, '_body_entered')
	pass

func _init():
	Moveable = Game.Moveable.new(self)

func reset_rotation():
	$Sprite.rotation_degrees = Moveable.get_closest_rotation()

func assign_target(target : Area2D):
	Moveable.assign_target(target)
	reset_rotation()

func move_home():
	Moveable.assign_target(Moveable.source)
	reset_rotation()
	Game.getTween().remove(self, 'position')
	Game.getWorld()._calculate_full_move_tween(self)
	

func target_destroyed(target):
	if LOG: Game.verbose(get_name() + ': Target destroyed')
	move_home()
	
func update_squad(planesData):
	type = Game.PLANE.FIGHTER
	for plane in planesData:
		if plane.type == Game.PLANE.BOMBER:
			type = Game.PLANE.BOMBER
			break
	if type == Game.PLANE.FIGHTER:
		Moveable.speed = Game.CONFIGURATION.fighterSquadSpeed
	else:
		Moveable.speed =  Game.CONFIGURATION.bomberSquadSpeed
	pass

func clean():
	emit_signal('object_destroyed', self)
	queue_free()

func follow_target():
	Game.getWorld()._calculate_move_tween(self)
	reset_rotation()

func catch_target():
	if Moveable.is_home():
		Game.getPlaneManager().ground_squad(self, Moveable.source)
		if LOG: Game.verbose('Squad landing')
		clean()
	else:
		attack_target()
		move_home()

func attack_target():
	var target = Moveable.target
	if target.is_in_group('Structure'):
		attack_structure()
	elif target.is_in_group('Transport'):
		attack_transport()
	elif target.is_in_group('Squad'):
		attack_squad()
	elif target.is_in_group('Border'):
		attack_border()

func list_planes() -> Array:
	return Game.getPlaneManager().list_planes(self)

func attack_border():
	var border : Border = Moveable.target as Border
	for plane in list_planes():
		if plane.type == Game.PLANE.BOMBER:
			border.change_power(ownerIdx, Game.CONFIGURATION.squadBorderBombardAddPower)
			border.change_power((ownerIdx + 1) % 2, -Game.CONFIGURATION.squadBorderBombardHitPoints)

func attack_structure():
	for plane in list_planes():
		if plane.type == Game.PLANE.BOMBER:
			Moveable.hit_target(Game.CONFIGURATION.squadStructureBombardHitPoints)

func attack_transport():
	for plane in list_planes():
		if can_bombard_transport(plane):
			Moveable.hit_target(100)

func can_bombard_transport(plane):
	return plane.type == Game.PLANE.BOMBER and (randi() % 100 <= Game.CONFIGURATION.squadTransportBombardDestoryChance)

func attack_squad():
	var squadPlanes = list_planes()
	var targetPlanes = Moveable.get_target_planes()
	
	# Algorithm - hit random from oposite side
	attack_planes(squadPlanes, targetPlanes)
	attack_planes(targetPlanes, squadPlanes)
	# destroy planes, which has 0 hit points
	remove_destroyed_planes(squadPlanes)
	remove_destroyed_planes(targetPlanes)
	# validate squads
	if squadPlanes.empty():
		clean()
	if targetPlanes.empty():
		Moveable.target.clean()

func remove_destroyed_planes(squadPlanes):
	var destroyed = []
	for plane in squadPlanes:
		if plane.Destructable.is_destroyed():
			destroyed.append(plane)
	for plane in destroyed:
		squadPlanes.erase(plane)

func attack_planes(squadPlanes, targetPlanes):
	for plane in squadPlanes:
		var targetPlane = targetPlanes[randi() % targetPlanes.size()]
		var hitPoints
		if plane.type == Game.PLANE.BOMBER:
			hitPoints = Game.CONFIGURATION.squadBomberHitPoints
		elif plane.type == Game.PLANE.FIGHTER:
			hitPoints = Game.CONFIGURATION.squadFighterHitPoints
		targetPlane.Destructable.hit(hitPoints)

func get_type():
	return type

func get_info():
	var planes : Array = list_planes()
	var fighters : int = 0
	var bombers : int = 0
	
	for plane in planes:
		if plane.type == Game.PLANE.BOMBER:
			bombers += 1
		elif plane.type == Game.PLANE.FIGHTER:
			fighters += 1
	return Game.playerDefinitions[ownerIdx].name + ' squad (' + str(fighters) + ':' + str(bombers) + ')'

func _body_entered(body):
	if Moveable.target == body:
		catch_target()
