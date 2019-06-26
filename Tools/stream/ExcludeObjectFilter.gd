# Exclude objects from the list
class_name ExcludeObjectFilter
extends ObjectFilter

var excludes : Array
func _init(excludes : Array):
	self.excludes = excludes
		
func filter_objects(objects : Array) -> Array:
	for exclude in excludes:
		objects.erase(exclude)
	return objects
