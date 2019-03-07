extends Node

func _ready():
	pass

func create_data(obj):
	if not obj.data.has('planes'):
		obj.data.planes = []
	return obj.data.planes

func add_plane(obj, plane):
	var planes = create_data(obj)
	planes.append(plane)
	obj.emit_signal('update_planes', obj, planes)

func get_planes_data(obj):
	return create_data(obj)

func add_planes(obj, planesData):
	var planes = create_data(obj)
	for plane in planesData:
		planes.append(plane)
	obj.emit_signal('update_planes', obj, planes)
	
func rem_planes(obj, planesData):
	var planes = create_data(obj)
	for plane in planesData:
		planes.erase(plane)
	obj.emit_signal('update_planes', obj, planes)

func rem_all_planes(obj):
	var planes = create_data(obj)
	planes.clear()

func move_planes(source, target, planes):
	rem_planes(source, planes)
	add_planes(target, planes)

