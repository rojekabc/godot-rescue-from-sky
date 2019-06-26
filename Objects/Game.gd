extends Node

enum STRUCTURE {CITY, VILLAGE, BUNKER, AIRPORT, FACTORY, CAPITAL}
enum RESOURCE {MANPOWER, FOOD, ARMY, AIRPLANE}
enum PLANE{FIGHTER, BOMBER}
enum PlaneState {FLY, ONGROUND}

var timetick = 0
var armyId = 0 setget ,get_army_id

# Object Types
const OBJECT_STRUCTURE : int = 1
const OBJECT_BORDER : int = 2
const OBJECT_TRANSPORT : int = 4
const OBJECT_ARMY : int = 8
const OBJECT_SQUAD : int = 16
const OBJECT_ALL : int =  OBJECT_STRUCTURE | OBJECT_BORDER | OBJECT_TRANSPORT | OBJECT_ARMY | OBJECT_SQUAD

# Materials
var neutralMaterial

# Scenes
var Structure : Area2D
var Transport : Area2D
var Squad : Area2D
var Army : Area2D
var Border : Area2D

const STRUCTURE_COLLISION_LAYER = 1
const TRANSPORT_COLLISION_LAYER = 2
const BORDER_COLLISION_LAYER = 4
const ARMY_COLLISION_LAYER = 8
const SQUAD_COLLISION_LAYER = 16

const BORDER_COLLISION_MASK = STRUCTURE_COLLISION_LAYER
const ALL_COLLISION_MASK = STRUCTURE_COLLISION_LAYER | TRANSPORT_COLLISION_LAYER | BORDER_COLLISION_LAYER | ARMY_COLLISION_LAYER | SQUAD_COLLISION_LAYER

enum SCENE {START, GAME}

# interfaces
var Moveable = preload('res://Interfaces/Moveable.gd')
#warning-ignore:unused_class_variable
var Destructable = preload('res://Interfaces/Destructable.gd')
#warning-ignore:unused_class_variable
var Consumer = preload('res://Interfaces/Consumer.gd')
#warning-ignore:unused_class_variable
var Producer = load('res://Interfaces/Producer.gd')

const TEST_CONFIGURATION = {
		verbose = true,
		loggers = ['ClickLog'],
		transportSpeed = 20, # number of units (unit is a distance between structures) per second
		fighterSquadSpeed = 90,
		bomberSquadSpeed = 60,
		airportLimit = [3, 3],
		squadStructureBombardHitPoints = 20,
		squadTransportBombardDestoryChance = 100,
		squadFighterHitPoints = 60,
		squadBomberHitPoints = 5,
		squadBorderBombardAddPower = 5,
		squadBorderBombardHitPoints = 5,
		squadBomberLimit = 3,
		squadFighterLimit = 3,
		timertick = 1,
		borderScannerTick = 3,
		armyPower = 20,
		borderMinimumPowerMultiplier = 1,
		borderMaximumPowerMultiplier = 10,
		borderMaximumAttackChance = 0.3,
		borderPowerReduceAttackerMultplier = 0.5,
		borderPowerReduceDefenderMultplier = 1.0
	}

const GAME_CONFIGURATION = {
		verbose = false,
		loggers = [],
		transportSpeed = 20, # number of units (unit is a distance between structures) per second
		fighterSquadSpeed = 90,
		bomberSquadSpeed = 60,
		airportLimit = [6, 6],
		airportFighterLimit = 6,
		airportBomberLimit = 6,
		squadStructureBombardHitPoints = 20,
		squadTransportBombardDestoryChance = 30,
		squadFighterHitPoints = 30,
		squadBomberHitPoints = 5,
		squadBorderBombardAddPower = 5,
		squadBorderBombardHitPoints = 5,
		squadBomberLimit = 3,
		squadFighterLimit = 3,
		timertick = 3,
		borderScannerTick = 3,
		armyPower = 20,
		borderMinimumPowerMultiplier = 1,
		borderMaximumPowerMultiplier = 10,
		borderMaximumAttackChance = 0.3,
		borderPowerReduceAttackerMultplier = 0.5,
		borderPowerReduceDefenderMultplier = 1.0
	}

var CONFIGURATION = TEST_CONFIGURATION
var borderMinimum
var borderMaximum
var borderPowerReduceAttacker
var borderPowerReduceDefender

const resourceDefinitions = {}
const structureDefinitions = {}
const playerDefinitions = []

const MAP_WIDTH = 1024
const MAP_HEIGHT = 600

func get_army_id():
	armyId += 1
	return armyId

func create(temporary):
	var result = temporary.duplicate()
	var props = result.get_property_list()
	for prop in props:
		match prop.name:
			'Moveable': result.Moveable = Moveable.new(result)
			'Destructable': result.Destructable = Destructable.new(result)
	return result

func verbose(msg):
	if CONFIGURATION.verbose:
		print(str(timetick) + ' : ' + msg)

func getWorld() -> GameWorld:
	return get_tree().get_root().get_node('World') as GameWorld

func getTimer():
	return get_tree().get_root().get_node('World/Timer') as Timer

func getTween():
	return get_tree().get_root().get_node('World/Tween') as Tween

func getPlaneManager() -> PlaneManager:
	return get_tree().get_root().get_node('World/Map/PlaneManager') as PlaneManager

func changeScene(scene : int) -> void:
	match scene:
		SCENE.START:
			get_tree().change_scene('res://Scenes/GUIStart.tscn')
		SCENE.GAME:
			get_tree().change_scene('res://Scenes/World.tscn')

func _ready():
	structureDefinitions[STRUCTURE.CITY] = {
		name = 'City',
		type = STRUCTURE.CITY,
		acronym = 'C',
		consumes = [],
		produces = [RESOURCE.MANPOWER]
	}
	structureDefinitions[STRUCTURE.VILLAGE] = {
		name = 'Village',
		type = STRUCTURE.VILLAGE,
		acronym = 'V',
		consumes = [],
		produces = [RESOURCE.FOOD]
	}
	structureDefinitions[STRUCTURE.BUNKER] = {
		name = 'Bunker',
		type = STRUCTURE.BUNKER,
		acronym = 'B',
		consumes = [],
		produces = [RESOURCE.ARMY]
	}
	structureDefinitions[STRUCTURE.AIRPORT] = {
		name = 'Airport',
		type = STRUCTURE.AIRPORT,
		acronym = 'A',
		consumes = [RESOURCE.AIRPLANE],
		produces = []
	}
	structureDefinitions[STRUCTURE.FACTORY] = {
		name = 'Factory',
		type = STRUCTURE.FACTORY,
		acronym = 'F',
		consumes = [],
		produces = [RESOURCE.AIRPLANE]
	}
	structureDefinitions[STRUCTURE.CAPITAL] = {
		name = 'Capital',
		type = STRUCTURE.CAPITAL,
		acronym = 'HQ',
		consumes = [],
		produces = [RESOURCE.MANPOWER, RESOURCE.ARMY]
	}
	
	resourceDefinitions[RESOURCE.MANPOWER] = {
		name = 'Manpower',
		consumes = [RESOURCE.FOOD],
		timeout = 5,
		acronym = 'M'
	}
	resourceDefinitions[RESOURCE.FOOD] = {
		name = 'Food',
		consumes = [],
		timeout = 1,
		acronym = 'F'
	}
	resourceDefinitions[RESOURCE.ARMY] = {
		name = 'Army',
		consumes = [RESOURCE.MANPOWER, RESOURCE.FOOD],
		timeout = 10,
		acronym = 'S'
	}
	resourceDefinitions[RESOURCE.AIRPLANE] = {
		name = 'Airplane',
		consumes = [RESOURCE.MANPOWER],
		timeout = 20,
		acronym = 'A'
	}
	
	# Scenes
	Structure = load('res://Scenes/Structure.tscn').instance()
	Transport = load('res://Scenes/Transport.tscn').instance()
	Squad = load('res://Scenes/Squad.tscn').instance()
	Army = load('res://Scenes/Army.tscn').instance()
	Border = load('res://Scenes/Border.tscn').instance()

	# Calculate value of static variables
	borderMinimum = CONFIGURATION.armyPower * CONFIGURATION.borderMinimumPowerMultiplier
	borderMaximum = CONFIGURATION.armyPower * CONFIGURATION.borderMaximumPowerMultiplier
	borderPowerReduceAttacker = CONFIGURATION.armyPower * CONFIGURATION.borderPowerReduceAttackerMultplier
	borderPowerReduceDefender = CONFIGURATION.armyPower * CONFIGURATION.borderPowerReduceDefenderMultplier

	pass
