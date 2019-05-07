class_name StatusLabel
extends Label

var startTick
export var show_duration = 2
export var STATUS_COLOR = Color(1, 1, 1, 0.6)
export var INFO_COLOR = Color(0, 1, 1, 0.6)
export var FAIL_COLOR = Color(1, 0, 0, 0.6)

signal stop_showing

func _ready():
	visible = false
	Game.getTimer().connect('timeout', self, '_timeout')
	pass
	
func _timeout():
	if visible and Game.timetick > startTick + show_duration:
		visible = false
		emit_signal('stop_showing')
	pass

func _status(msg, color):
	text = msg
	modulate = color
	visible = true
	startTick = Game.timetick
	

func status(msg):
	_status(msg, STATUS_COLOR)
	pass

func info(msg):
	_status(msg, INFO_COLOR)

func fail(msg):
	_status(msg, FAIL_COLOR)
