class_name StatusLabel
extends Label

export var show_duration = 2
export var STATUS_COLOR = Color(1, 1, 1, 0.6)
export var INFO_COLOR = Color(0, 1, 1, 0.6)
export var FAIL_COLOR = Color(1, 0, 0, 0.6)

var timer : SceneTreeTimer

signal stop_showing

func _ready():
	visible = false
	
func _timeout():
	timer = null
	visible = false
	emit_signal('stop_showing')

func _status(msg, color):
	text = msg
	modulate = color
	visible = true
	if timer:
		timer.disconnect('timeout', self, '_timeout')
	if show_duration > 0:
		timer = get_tree().create_timer(show_duration)
		timer.connect('timeout', self, '_timeout')

func status(msg):
	_status(msg, STATUS_COLOR)
	pass

func info(msg):
	_status(msg, INFO_COLOR)

func fail(msg):
	_status(msg, FAIL_COLOR)
