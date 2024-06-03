extends Node


@export var world_seed: int = -1
@export var world_scalar:float = 1
@export var star_scalar:float = 25
@export var planet_scalar:float = 5
@export var vehicle_scalar:float = 1
@export var planet_distance_scalar: float = 100
@export var moon_dist_scalar:float = 1.5
@export var orbit_speed_scalar: float = 0.5

@export var min_planets:int = 2
@export var max_planets:int = 10
@export var min_moons:int = 0
@export var max_moons:int = 3

@export var planet:PackedScene
@export var cargo_ship:PackedScene
@export var cargo_timer_scene:PackedScene

var planet_name_list: Array
var moon_name_list: Array
var camera:Node3D
var star_name:String

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set Seed
	if world_seed < 0:
		world_seed = randi()
	seed(world_seed)
	print("Seed: %d" % world_seed)
	
	# Create Star
	star_scalar *= randf_range(0.5, 2)
	var light = $Star/OmniLight3D as OmniLight3D
	$Star/StarMesh.scale *= star_scalar * world_scalar
	light.omni_range *= planet_distance_scalar * star_scalar * world_scalar * max_planets
	light.light_size = star_scalar
	light.light_energy *= star_scalar * world_scalar * 4
	light.light_indirect_energy = sqrt(light.light_energy)
	star_name = Names.STAR_NAMES.pick_random()
	
	# Create Planets
	planet_name_list = Names.PLANET_NAMES.duplicate(true)
	moon_name_list = Names.MOON_NAMES.duplicate(true)
	create_planets()
	planet_name_list.clear() #free up mem
	moon_name_list.clear()
	
	# Set Camera Settings
	camera = $CameraPivot
	camera.max_zoom *= world_scalar
	
	#UI
	$UI.make_planet_ui()
	$UI.populate_planet_list()
	$UI.camera = camera
	$UI.set_star_name(star_name)
	
	#new_cargo_lanes()


func create_planets():
	var planet_count = randi_range(min_planets, max_planets)
	var last_dist = star_scalar*1.5*world_scalar
	
	for i in range(planet_count):
		var new_planet = planet.instantiate()
		var planet_size = randf_range(planet_scalar*world_scalar / 2, 2 * planet_scalar*world_scalar)
		
		# edit this function to call it again for moons
		var moon_count = randi_range(min_moons, max_moons)
		var last_moon_dist = planet_size * moon_dist_scalar
			
		for j in range(moon_count):
			var new_moon = planet.instantiate()
			var next_moon_dist = randf_range(last_moon_dist, (j+1) * planet_size * moon_dist_scalar)
			var moon_size = randf_range(planet_size * 0.1, planet_size * 0.5)
			var moon_name =  'No moon names left'
			if moon_name_list.size() > 0:
				moon_name = moon_name_list.pop_at(randi() % moon_name_list.size())
			new_moon.initialize(
				randf() * planet_scalar * world_scalar * orbit_speed_scalar * moon_dist_scalar,
				next_moon_dist,
				randf() * 15,
				randf(),
				moon_size,
				moon_name
			)
			last_moon_dist = next_moon_dist + moon_size
			new_moon.add_to_group("orbit_body")
			new_moon.add_to_group("moons")
			new_planet.add_child(new_moon)
			new_moon.planet_selected.connect(
				Callable($CameraPivot, "_on_planet_selected")
			)
		
		last_dist += last_moon_dist
		var next_dist = randf_range(last_dist, planet_distance_scalar * (i+1) * world_scalar)
		var planet_name = 'No planet names left'
		if planet_name_list.size() > 0:
			planet_name = planet_name_list.pop_at(randi() % planet_name_list.size())
			
		new_planet.initialize(
			randf()*world_scalar*planet_scalar*orbit_speed_scalar, 
			next_dist, 
			randf() * 15, 
			randf(), 
			planet_size,
			planet_name
		)
		
		last_dist = next_dist + last_moon_dist
		new_planet.add_to_group("orbit_body")
		new_planet.add_to_group("planets")
		new_planet.planet_selected.connect(
			Callable($CameraPivot, "_on_planet_selected")
		)
		$Star.add_child(new_planet)


func _input(event):
	if event.is_action_pressed("pause_planet_movement"):
		$SetCargoLanes.paused = not $SetCargoLanes.paused
		var cargo_timers = get_tree().get_nodes_in_group("cargo_timers")
		for timer in cargo_timers:
			timer.paused = not timer.paused


func _on_check_box_toggled(toggled_on):
	get_tree().call_group("orbit_body", "toggle_orbit", toggled_on)


func _on_set_cargo_lanes_timeout():
	get_tree().call_group("cargo_timers", "queue_free")
	new_cargo_lanes()
	
	
func new_cargo_lanes():
	var planets = get_tree().get_nodes_in_group("orbit_body")
	
	var cargo_lanes = randi_range(5, planets.size() / 2)
	print("Creating at most %d cargo lanes" % cargo_lanes)
	for i in cargo_lanes:
		if planets.size() < 2:
			break
		var cargo_timer = cargo_timer_scene.instantiate()
		cargo_timer.autostart = true
		cargo_timer.wait_time = randf_range(.5 , 1.5)
		cargo_timer.source = planets.pop_at(randi() % planets.size())
		cargo_timer.destination = planets.pop_at(randi() % planets.size())
		cargo_timer.timeout.connect(
			Callable(self, "_on_cargo_timer_timeout").bind(cargo_timer))
		cargo_timer.add_to_group("cargo_timers")
		add_child(cargo_timer)


func _on_cargo_timer_timeout(timer:Timer):
	var ship = cargo_ship.instantiate()
	ship.initialize(
		timer.destination, 
		timer.source, 
		vehicle_scalar*world_scalar)
	timer.source.body.add_child(ship)


func _on_ui_star_select():
	camera.go_to_star(false)


#func create_planet(moon_count, parent, size, min_dist, max_dist):
	#pass
