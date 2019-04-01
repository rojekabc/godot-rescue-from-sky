class_name OwnerMap
extends Node

const PIXEL_WIDTH = 30
const PIXEL_HEIGHT = 30
const WIDTH = 1024/PIXEL_WIDTH
const HEIGHT = 600/PIXEL_HEIGHT

var map : PoolByteArray = PoolByteArray()

func _init():
	# Divide by halth whole map
	for y in range(0, HEIGHT):
		for x in range(0, WIDTH):
			if x < WIDTH/2:
				map.append(0)
			else:
				map.append(1)
	# Random enemy point
	# var pos = randi() % (WIDTH*HEIGHT)
	# if map[pos] == 0: map[pos] = 1
	# else: map[pos] = 0
	pass

func get_at(pos : Vector2) -> int:
	return map[pos.x + pos.y*WIDTH]

func set_at(pos : Vector2, v : int) -> void:
	map[pos.x+pos.y*WIDTH] = v
	
func place_borders(var node : Node2D) -> void:
	for border in list_horizontal_borders():
		node.add_child(border)
	for border in list_vertical_borders():
		node.add_child(border)

func create_border(from : Vector2, to : Vector2):
	if (from.x < 0 or to.x < 0 or from.x >= WIDTH or to.x >= WIDTH
		or from.y < 0 or to.y < 0 or from.y >= HEIGHT or to.y >= HEIGHT):
			return null
	var diff : Vector2 = from - to
	var border : Area2D = Game.Border.duplicate().setup(from, to)
	match diff:
		Vector2.DOWN:
				border.position = Vector2(from.x*PIXEL_WIDTH + PIXEL_WIDTH/2, from.y*PIXEL_HEIGHT)
				border.rotation_degrees = 90
		Vector2.UP:
				border.position = Vector2(to.x*PIXEL_WIDTH + PIXEL_WIDTH/2, to.y*PIXEL_HEIGHT)
				border.rotation_degrees = 90
		Vector2.LEFT:
			border.position = Vector2(to.x*PIXEL_WIDTH, to.y*PIXEL_HEIGHT + PIXEL_HEIGHT/2)
		Vector2.RIGHT:
			border.position = Vector2(from.x*PIXEL_WIDTH, from.y*PIXEL_HEIGHT + PIXEL_HEIGHT/2)
	return border

func list_horizontal_borders() -> Array:
	var result : Array = []
	# search by rows
	for y in range(0, HEIGHT):
		# keep previous value
		var prev : int = map[y*WIDTH]
		for x in range(0, WIDTH):
			var cur : int = map[x + y*WIDTH]
			if prev != cur:
				result.append(create_border(Vector2(x-1, y), Vector2(x, y)))
			prev = cur
	
	return result

func list_vertical_borders() -> Array:
	var result : Array = []
	# search by columns
	for x in range(0, WIDTH):
		# keep previous value
		var prev : int = map[x]
		for y in range(0, HEIGHT):
			var cur : int = map[x + y*WIDTH]
			if prev != cur:
				result.append(create_border(Vector2(x, y-1), Vector2(x, y)))
			prev = cur
	
	return result