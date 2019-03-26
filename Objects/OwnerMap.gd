class_name OwnerMap

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
	pass

func get_at(x : int, y : int) -> int:
	return map[x + y*WIDTH]

func set_at(x:int, y:int, v:int) -> void:
	map[x+y*WIDTH] = v
	
func place_borders(var node : Node2D) -> void:
	for border in list_horizontal_borders():
		node.add_child(border)
	for border in list_vertical_borders():
		node.add_child(border)

func list_horizontal_borders() -> Array:
	var result : Array = []
	
	# search by rows
	for y in range(0, HEIGHT):
		# keep previous value
		var prev : int = map[y*WIDTH]
		for x in range(0, WIDTH):
			var cur : int = map[x + y*WIDTH]
			if prev != cur:
				var border : Area2D = Game.Border.duplicate().setup(Vector2(x-1, y), Vector2(x, y))
				border.position = Vector2(x*PIXEL_WIDTH, y*PIXEL_HEIGHT + PIXEL_HEIGHT/2)
				result.append(border)
			prev = cur
	
	return result

func list_vertical_borders() -> Array:
	var result : Array = []
	
	# search by rows
	for x in range(0, WIDTH):
		# keep previous value
		var prev : int = map[x]
		for y in range(0, HEIGHT):
			var cur : int = map[x + y*WIDTH]
			if prev != cur:
				var border : Area2D = Game.Border.duplicate().setup(Vector2(x, y-1), Vector2(x, y))
				border.position = Vector2(x*PIXEL_WIDTH + PIXEL_WIDTH/2, y*PIXEL_HEIGHT)
				border.rotation_degrees = 90
				result.append(border)
			prev = cur
	
	return result