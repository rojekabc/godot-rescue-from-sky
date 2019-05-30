class_name PlaneManager
extends Node

var planes = []
var pilots = []

signal update_planes(planeHolder, planes)

func create_plane(ownerIdx : int, type : int, airport : Structure) -> AirPlane:
	var airplane : AirPlane = AirPlane.new(type).owner(ownerIdx).ground(airport)
	planes.append(airplane)
	emit_signal('update_planes', airport, list_planes(airport))
	return airplane

func ground_squad(squad : Squad, airport : Structure):
	ground(list_planes(squad), airport)

func ground(planes : Array, airport : Structure):
	for object in planes:
		var plane : AirPlane = object
		plane.ground(airport)
	emit_signal('update_planes', airport, list_planes(airport))

func fly(planes : Array, squad : Squad):
	var airport : Structure
	for object in planes:
		var plane : AirPlane = object
		airport = plane.baseAirport
		plane.fly(Pilot.new(), squad) # TODO: empty random pilot
	squad.update_squad(planes)
	emit_signal('update_planes', airport, list_planes(airport))
	# emit_signal('update_planes', squad, list_assigned_to_squad(squad))

func etoi(e : int) -> int:
	return e

func count_assigned_planes(airport : Structure) -> Dictionary:
	var result = {}
	for type in Game.PLANE.values():
		result[type] = 0
	for plane in planes:
		if plane.baseAirport != airport:
			continue
		result[plane.type] += 1
	return result

func list_planes(planeHolder) -> Array:
	var result : Array = []
	if planeHolder is Structure:
		for plane in planes:
			if plane.is_ground(planeHolder):
				result.append(plane)
	elif planeHolder is Squad:
		for plane in planes:
			if plane.squad == planeHolder:
				result.append(plane)
	return result