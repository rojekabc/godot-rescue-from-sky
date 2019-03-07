var object

var planes = []

func _init(object):
	self.object = object

func add_plane(plane):
	planes.append(plane)
	object.emit_signal('update_planes', object, planes)

func add_planes(planesData):
	for plane in planesData:
		planes.append(plane)
	object.emit_signal('update_planes', object, planes)
	
func rem_planes(planesData):
	for plane in planesData:
		planes.erase(plane)
	object.emit_signal('update_planes', object, planes)

func rem_all_planes():
	planes.clear()
	object.emit_signal('update_planes', object, planes)

func move_planes(target):
	target.PlaneHolder.add_planes(planes)
	rem_all_planes()

