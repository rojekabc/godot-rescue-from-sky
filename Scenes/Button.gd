extends Button

func _ready():
	connect('pressed', self, '_pressed')

func _pressed():
	Game.changeScene(Game.SCENE.START)

