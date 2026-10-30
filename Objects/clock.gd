extends Node3D
var minRotation
var hourLerpWeight
var minLerpWeight
var hourRotation
var hour
var hour12
var hour24
var min
var currentTime
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentTime = Time.get_datetime_dict_from_system()
	hour24 = currentTime.get("hour")
	hour12 = 0
	if (hour24 >= 12):
		hour12 = hour24 - 12
	hour = hour12
	min = currentTime.get("minute")
	hourLerpWeight = hour/12 
	minLerpWeight = min/360	
	hourRotation = lerp(0, 360, hourLerpWeight)
	minRotation = lerp(0, 360, minLerpWeight)
	print(hourLerpWeight)
	print(minLerpWeight)
	print(hourRotation)
	print(minRotation)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
