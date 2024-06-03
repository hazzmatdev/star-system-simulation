extends Pausable

class_name CargoSource

var object_name: String
var inventory: Array[Product]
var body: Node3D # Body is the actual on screen object that the cargo is coming from


func create_cargo_lane_timed(destination:CargoSource, timer:float):
	print("Creating a cargo lane from %s to %s with wait time %.2f" % [object_name, destination.object_name, timer])
	var cargo_timer = CargoTimer.new()
	add_child(cargo_timer)
	cargo_timer.source = self
	cargo_timer.destination = destination
	cargo_timer.wait_time = timer


#func create_cargo_lane_on_cargo_percent(destination:CargoSource):
	#pass
