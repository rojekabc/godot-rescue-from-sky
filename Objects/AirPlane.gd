var type
var ownerIdx
var data = {}
	
func _init(ownerIdx, airplaneType):
	self.type = airplaneType
	self.ownerIdx = ownerIdx
	pass

func get_name():
	var planeTypeName = 'UFO'
	match type:
		Game.FIGHTER: planeTypeName = 'Fighter'
		Game.BOMBER: planeTypeName = 'Bomber'
	return Game.playerDefinitions[ownerIdx].name + '.' + planeTypeName