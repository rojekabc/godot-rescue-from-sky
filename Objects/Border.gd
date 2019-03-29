extends Area2D
class_name Border

signal object_destroyed(object)

var from : Vector2
var to : Vector2
var playerPower : PoolRealArray = PoolRealArray()

var neutral : bool
var winPlayer : int

func setup(from : Vector2, to : Vector2) -> Border:
	self.from = from
	self.to = to
	for i in range(0, Game.playerDefinitions.size()):
		playerPower.append(0.0)
	return self

func _ready():
	update_color()

func is_for(var from : Vector2, var to : Vector2) -> bool:
	return (self.from == from and self.to == to) or (self.from == to and self.to == from)

func has(pos : Vector2) -> bool:
	return from == pos || to == pos

func get_direction(pos : Vector2) -> Vector2:
	if pos == from:
		return to - pos
	elif pos == to:
		return from - pos
	return Vector2.ZERO

func change_power(var playerId : int, var powerChange : float) -> void:
	playerPower[playerId] = clamp(playerPower[playerId] + powerChange, 0, 100)
	update_color()

func update_state() -> void:
	var result : PoolIntArray = Tool.array_min_max_idx(playerPower)
	neutral = result[0] == result[1]
	winPlayer = result[1]

func update_color() -> void:
	update_state()
	if neutral:
		$Sprite.material = Game.neutralMaterial
	else:
		$Sprite.material = Game.playerDefinitions[winPlayer].armyMaterial
	pass

func is_neutral() -> bool:
	return neutral

func is_attacking() -> bool:
	return not neutral and playerPower[winPlayer] > 80

func get_win_player() -> int:
	return winPlayer

func get_win_power() -> float:
	return playerPower[winPlayer]

func get_attack_point(ownerMap : OwnerMap):
	if ownerMap.get_at(from) != winPlayer:
		return from
	if ownerMap.get_at(to) != winPlayer:
		return to

func get_name() -> String:
	return "Border " + str(from) + " : " + str(to)

func destroy():
	emit_signal('object_destroyed', self)
	queue_free()
