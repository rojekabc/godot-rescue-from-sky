class_name ObjectStream

var objects : Array
	
func _init(objects : Array):
	self.objects = objects
	pass
		
func append(objects : Array):
	for object in objects:
		self.objects.append(object)
	
func filter(filter : ObjectFilter) -> ObjectStream:
	filter.filter_objects(objects)
	return self
	
func objects() -> Array:
	return objects
	
func first():
	if objects.empty():
		return null
	return objects[0]