extends Timer

class_name CargoTimer

var source:CargoSource
var destination:CargoSource
var cargo_ship:PackedScene
var vehicle_scalar:float = 1
var world_scalar:float = 1

func _ready():
	autostart = true
	var main = get_tree().current_scene
	add_to_group("cargo_timers")
	timeout.connect(Callable(self, "_on_cargo_timer_timeout").bind(self))
	if main.is_node_ready():
		cargo_ship = main.cargo_ship
		vehicle_scalar = main.vehicle_scalar
		world_scalar = main.world_scalar

func _on_cargo_timer_timeout(timer:Timer):
	var ship = cargo_ship.instantiate()
	ship.initialize(
		timer.destination, 
		timer.source, 
		vehicle_scalar*world_scalar)
	timer.source.body.add_child(ship)
	#These print a lot to console, good for debugging tho!
	#print("Cargo ship from %s going to %s sent" % [source.object_name, destination.object_name])
