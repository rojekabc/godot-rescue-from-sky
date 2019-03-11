extends Node

enum STRUCTURE {CITY, VILLAGE, BUNKER, AIRPORT, FACTORY, CAPITAL}
enum RESOURCE {MANPOWER, FOOD, ARMY, AIRPLANE}
enum PLANE{FIGHTER, BOMBER}

var timetick = 0
var AirPlane = preload('res://Objects/AirPlane.gd')

# interfaces
var Targetable = preload('res://Interfaces/Targetable.gd')
var Moveable = preload('res://Interfaces/Moveable.gd')
var PlaneHolder = preload('res://Interfaces/PlaneHolder.gd')
var Destructable = preload('res://Interfaces/Destructable.gd')
var Consumer = preload('res://Interfaces/Consumer.gd')
var Producer = preload('res://Interfaces/Producer.gd')

const TEST_CONFIGURATION = {
		verbose = true,
		transportSpeed = 20, # number of units (unit is a distance between structures) per second
		fighterSquadSpeed = 90,
		bomberSquadSpeed = 60,
		airportFighterLimit = 100,
		airportBomberLimit = 100,
		squadStructureBombardHitPoints = 20,
		squadTransportBombardDestoryChance = 100,
		squadFighterHitPoints = 60,
		squadBomberHitPoints = 5
	}

const GAME_CONFIGURATION = {
		verbose = false,
		transportSpeed = 20, # number of units (unit is a distance between structures) per second
		fighterSquadSpeed = 90,
		bomberSquadSpeed = 60,
		airportFighterLimit = 100,
		airportBomberLimit = 100,
		squadStructureBombardHitPoints = 20,
		squadTransportBombardDestoryChance = 30,
		squadFighterHitPoints = 30,
		squadBomberHitPoints = 5
	}

var CONFIGURATION = GAME_CONFIGURATION

const resourceDefinitions = {}
const structureDefinitions = {}
const playerDefinitions = []

const MAP_WIDTH = 1024
const MAP_HEIGHT = 600

func verbose(msg):
	if CONFIGURATION.verbose:
		print(str(timetick) + ' : ' + msg)

func getWorld():
	return get_tree().get_root().get_node('World')

func getTimer():
	return get_tree().get_root().get_node('World/Timer')

func _ready():
	structureDefinitions[CITY] = {
		name = 'City',
		type = CITY,
		acronym = 'C',
		consumes = [FOOD],
		produces = [MANPOWER]
	}
	structureDefinitions[VILLAGE] = {
		name = 'Village',
		type = VILLAGE,
		acronym = 'V',
		consumes = [],
		produces = [FOOD]
	}
	structureDefinitions[BUNKER] = {
		name = 'Bunker',
		type = BUNKER,
		acronym = 'B',
		consumes = [FOOD, MANPOWER],
		produces = [ARMY]
	}
	structureDefinitions[AIRPORT] = {
		name = 'Airport',
		type = AIRPORT,
		acronym = 'A',
		consumes = [AIRPLANE],
		produces = []
	}
	structureDefinitions[FACTORY] = {
		name = 'Factory',
		type = FACTORY,
		acronym = 'F',
		consumes = [MANPOWER],
		produces = [AIRPLANE]
	}
	structureDefinitions[CAPITAL] = {
		name = 'Capital HQ',
		type = CAPITAL,
		acronym = 'HQ',
		consumes = [FOOD, MANPOWER],
		produces = [MANPOWER, ARMY]
	}
	
	resourceDefinitions[MANPOWER] = {
		name = 'Manpower',
		consumes = [FOOD],
		timeout = 5,
		acronym = 'Mp'
	}
	resourceDefinitions[FOOD] = {
		name = 'Food',
		consumes = [],
		timeout = 1,
		acronym = 'F'
	}
	resourceDefinitions[ARMY] = {
		name = 'Army',
		consumes = [MANPOWER, FOOD],
		timeout = 10,
		acronym = 'A'
	}
	resourceDefinitions[AIRPLANE] = {
		name = 'Airplane',
		consumes = [MANPOWER],
		timeout = 20,
		acronym = 'Ap'
	}
	playerDefinitions.append({
			name = 'Zygfryd',
			color = Color(0.2, 0.0, 0.6, 0.5)
	})
	playerDefinitions.append({
			name = 'Godfryd',
			color = Color(0.6, 0.0, 0.2, 0.5)
	})

	pass
