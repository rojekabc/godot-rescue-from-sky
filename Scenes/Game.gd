extends Node

enum STRUCTURE {CITY, VILLAGE, BUNKER, AIRPORT, FACTORY, CAPITAL}
enum RESOURCE {MANPOWER, FOOD, ARMY, AIRPLANE}

var timetick = 0

const CONFIGURATION = {
		verbose = true,
		transportSpeed = 10 # number of units (unit is a distance between structures) per second
	}

const resourceDefinitions = {}
const structureDefinitions = {}
const playerDefinitions = []

const MAP_WIDTH = 1024
const MAP_HEIGHT = 600

func verbose(msg):
	if CONFIGURATION.verbose:
		print(str(timetick) + ' : ' + msg)

func getWorld():
	return get_tree().get_root().get_child(1) # .get_node('World')

func _ready():
	structureDefinitions[CITY] = {
		name = 'City',
		type = CITY,
		acronym = 'C',
		timerFunction = '_city_timeout',
		consumes = [FOOD],
		produces = [MANPOWER]
	}
	structureDefinitions[VILLAGE] = {
		name = 'Village',
		type = VILLAGE,
		acronym = 'V',
		timerFunction = '_village_timeout',
		consumes = [],
		produces = [FOOD]
	}
	structureDefinitions[BUNKER] = {
		name = 'Bunker',
		type = BUNKER,
		acronym = 'B',
		timerFunction = '_bunker_timeout',
		consumes = [FOOD, MANPOWER],
		produces = [ARMY]
	}
	structureDefinitions[AIRPORT] = {
		name = 'Airport',
		type = AIRPORT,
		acronym = 'A',
		timerFunction = '_airport_timeout',
		consumes = [AIRPLANE],
		produces = []
	}
	structureDefinitions[FACTORY] = {
		name = 'Factory',
		type = FACTORY,
		acronym = 'F',
		timerFunction = '_factory_timeout',
		consumes = [MANPOWER],
		produces = [AIRPLANE]
	}
	structureDefinitions[CAPITAL] = {
		name = 'Capital HQ',
		type = CAPITAL,
		acronym = 'HQ',
		timerFunction = '_capital_timeout',
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
