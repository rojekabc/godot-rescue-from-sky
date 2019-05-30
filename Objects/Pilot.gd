class_name Pilot

var name : String
var airport : Structure

func name(name : String) -> Pilot:
	self.name = name
	return self

func airport(airport : Structure) -> Pilot:
	self.airport = airport
	return self