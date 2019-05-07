class_name RuleOfWin
extends Node

func _ready():
	pass

func loose_game():
	Game.getWorld().get_node('UI/EndGame').visible = true
	Game.getWorld().get_node('UI/EndGame/Status').status('You Loose!')
	Game.getTimer().stop()
	Game.getTween().remove_all()

func win_game():
	Game.getWorld().get_node('UI/EndGame').visible = true
	Game.getWorld().get_node('UI/EndGame/Status').status('You Win!')
	Game.getTimer().stop()
	Game.getTween().remove_all()

func start_rule_take_capital(structures : Node2D):
	for node in structures.get_children():
		var structure : Structure = node as Structure
		if structure.type != Game.STRUCTURE.CAPITAL:
			continue
		if Game.playerDefinitions[structure.ownerIdx].type == Player.PlayerType.HUMAN_PLAYER:
			structure.connect('owner_changed', self, 'loose_game')
		else:
			structure.connect('owner_changed', self, 'win_game')