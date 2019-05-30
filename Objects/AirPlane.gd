class_name AirPlane

var type
var ownerIdx
var baseAirport : Structure
var Destructable : Destructable
var squad : Squad
var pilot : Pilot
var state : int

signal object_destroyed(object)

func destroy():
	emit_signal('object_destroyed', self)

func _init(type : int):
	self.type = type
	Destructable = Game.Destructable.new(self)

func owner(ownerIdx : int) -> AirPlane:
	self.ownerIdx = ownerIdx
	return self

func ground(airport : Structure) -> AirPlane:
	self.state = Game.PlaneState.ONGROUND
	self.squad = null
	self.baseAirport = airport
	if self.pilot:
		self.pilot.airport(airport)
	self.pilot = null
	return self

func fly(pilot : Pilot, squad : Squad) -> AirPlane:
	self.state = Game.PlaneState.FLY
	self.squad = squad
	self.pilot = pilot.airport(null)
	return self

func is_ground(airport = null) -> bool:
	return state == Game.PlaneState.ONGROUND and (airport == null or airport == self.baseAirport)

func is_fly() -> bool:
	return state == Game.PlaneState.FLY

func get_name():
	var planeTypeName = 'UFO'
	match type:
		Game.PLANE.FIGHTER: planeTypeName = 'Fighter'
		Game.PLANE.BOMBER: planeTypeName = 'Bomber'
	return Game.playerDefinitions[ownerIdx].name + '.' + planeTypeName