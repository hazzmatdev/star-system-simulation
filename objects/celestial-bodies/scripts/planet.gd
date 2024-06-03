extends CargoSource

class_name Planet

@export var orbital_velo: float = 50
@export var orbit_distance: float = 75 # This is calculated before incline
@export var orbit_incline: float # in degrees, prefer between -15 and 15
@export var orbit_init_progress: float # 0.0 to 1.0, percent progress along orbit
@export var planet_size: float = 5 # around 5

var orb_rads:float
var system_planet_velo := Vector3.ZERO
var last_pos := Vector3.ZERO
var planet_selecter_ready := false
var focused_by_camera := false

signal planet_selected

func initialize(velo:float, distance:float, incline:float, init_progress:float, size:float, planet_name:=''):
	orbital_velo = velo
	orbit_distance = distance
	orbit_incline = incline
	orbit_init_progress = init_progress
	planet_size = size
	object_name = planet_name
	
	$Planet.position.z = orbit_distance
	rotate_x(orbit_incline * PI / 180)
	rotate_y(orbit_init_progress * 2 * PI)
	$Planet/PlanetMesh.scale *= planet_size
	var orbit_dia = 2*orbit_distance + 0.5
	$Orbit.scale = Vector3(orbit_dia,orbit_dia,orbit_dia)
	set_orb_rad(orbital_velo)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	body = $Planet
	last_pos = $Planet.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if paused:
		return
	if get_parent() is Planet:
		global_position = get_parent().body.global_position
	transform = transform.rotated_local(Vector3.UP, orb_rads*delta)

func _input(event):
	if event.is_action_pressed("pause_planet_movement"):
		paused = not paused
	if planet_selecter_ready and event.is_action_pressed("ui_click"):
		if event.is_double_click():
			zoom_to_planet()
	if planet_selecter_ready and event.is_action_released("ui_click"):
		open_planet_ui()

func _on_planet_clicker_planet_clicked():
	zoom_to_planet()
	

func open_planet_ui():
	var ui = get_node_or_null(^"/root/Main/UI")
	if ui:
		ui.open_object_panel(self)

func zoom_to_planet():
	if not focused_by_camera:
		print("Zoom into " + object_name)
		focused_by_camera = true
		planet_selected.emit(self)
	
func set_orb_rad(velo:float):
	orb_rads = velo / (2 * PI * orbit_distance)


func toggle_orbit(toggle:bool):
	$Orbit.visible = toggle


func _on_area_3d_mouse_entered():
	planet_selecter_ready = true


func _on_area_3d_mouse_exited():
	planet_selecter_ready = false


func _on_planet_release(planet_release:Signal):
	planet_release.disconnect(Callable(self, "_on_planet_release"))
	focused_by_camera = false


func get_rad_squared():
	return (planet_size / 2)**2


func get_rad():
	return planet_size / 2
