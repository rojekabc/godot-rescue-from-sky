class_name NearestObjectFilter
extends ObjectFilter

var position : Vector2
	
func _init(position : Vector2):
	self.position = position
	
func filter_objects(objects : Array) -> Array:
	if objects.empty():
		return objects
	var nearest = objects[0]
	var distance = (nearest.position - position).length()
	for object in objects:
		var objectdistance = (object.position - position).length()
		if objectdistance < distance:
			distance = objectdistance
			nearest = object
	objects.clear()
	objects.append(nearest)
	return objects