var type
var ownerIdx

var Destructable

signal object_destroyed(object)

func destroy():
	emit_signal('object_destroyed', self)

func _init(ownerIdx, airplaneType):
	self.type = airplaneType
	self.ownerIdx = ownerIdx
	Destructable = Game.Destructable.new(self)

func get_name():
	var planeTypeName = 'UFO'
	match type:
		Game.FIGHTER: planeTypeName = 'Fighter'
		Game.BOMBER: planeTypeName = 'Bomber'
	return Game.playerDefinitions[ownerIdx].name + '.' + planeTypeName