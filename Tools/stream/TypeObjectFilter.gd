# Exclude objects with not included type
class_name TypeObjectFilter
extends ObjectFilter

var objectType : int
	
func _init(objectType : int):
	self.objectType = objectType

func filter_objects(objects : Array) -> Array:
	var remMarked : PoolIntArray = PoolIntArray()
	for pos in range(objects.size()):
		var object = objects[pos]
		if object.objectType & objectType:
			continue
		remMarked.append(pos)
	remMarked.invert()
	for pos in remMarked:
		objects.remove(pos)
	return objects