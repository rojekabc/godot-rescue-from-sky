class_name BorderScanner
extends Node

var scannedNode : Node2D
var ownerMap : OwnerMap
var timerTick : int

func _ready():
	scannedNode = get_parent().get_node("Borders")
	ownerMap = get_parent().get_node("OwnerMap")
	get_parent().get_parent().get_node("Timer").connect("timeout", self, "_timeout")
	reset_timer_tick()

func reset_timer_tick():
	timerTick = Game.CONFIGURATION.borderScannerTick

func _timeout():
	if timerTick == 0:
		reset_timer_tick()
		scan_borders()
	else:
		timerTick -= 1

func scan_borders():
	for border in scannedNode.get_children():
		if border.is_in_group('Border'):
			scan_border(border)

func list_borders(pos : Vector2) -> Dictionary:
	var result = {
		Vector2.UP : null,
		Vector2.DOWN : null,
		Vector2.LEFT : null,
		Vector2.RIGHT : null
	}
	for border in scannedNode.get_children():
		var direction = border.get_direction(pos)
		if direction == Vector2.ZERO:
			continue
		result[direction] = border
	return result
	
func scan_border(border : Border):
	if border.is_attacking() && border.random_attack():
		var attackPoint : Vector2 = border.get_attack_point(ownerMap)
		if attackPoint == null: # if it's already attacked
			return
		# TODO: VERY SIMPLE BORDER MOVE.
		ownerMap.set_at(attackPoint, border.get_win_player())
		attack_move_power_reduce(border, attackPoint)
	pass

func attack_move_power_reduce(border : Border, attackPoint : Vector2):
	var newPower : PoolRealArray
	for i in range(0, border.playerPower.size()):
		if i == border.get_win_player():
			newPower.append(border.playerPower[i] - Game.borderPowerReduceAttacker)
		else:
			newPower.append(border.playerPower[i] - Game.borderPowerReduceDefender)
	var borders = list_borders(attackPoint)
	for borderDirection in borders:
		var tborder = borders[borderDirection]
		if borders[borderDirection]:
			tborder.destroy()
		else:
			var newBorder = ownerMap.create_border(attackPoint, attackPoint + borderDirection)
			if newBorder:
				newBorder.set_powers(newPower)
				scannedNode.add_child(newBorder)
	pass

# move power from current attacking border to newly created without change
func attack_move_power(border : Border, attackPoint : Vector2):
	var borders = list_borders(attackPoint)
	for borderDirection in borders:
		var tborder = borders[borderDirection]
		if borders[borderDirection]:
			tborder.destroy()
		else:
			var newBorder = ownerMap.create_border(attackPoint, attackPoint + borderDirection)
			if newBorder:
				newBorder.set_powers(border.playerPower)
				scannedNode.add_child(newBorder)

# only border move, power will not move
func attack_base(attackPoint : Vector2):
	var borders = list_borders(attackPoint)
	for borderDirection in borders:
		var tborder = borders[borderDirection]
		if borders[borderDirection]:
			tborder.destroy()
		else:
			var newBorder = ownerMap.create_border(attackPoint, attackPoint + borderDirection)
			if newBorder:
				scannedNode.add_child(newBorder)