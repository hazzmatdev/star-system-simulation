extends Node3D

@export var camera_pan_speed: float = 100
@export var camera_zoom_speed: float = 20
@export var camera_sens: float = 0.4
@export var max_planet_zoom: float = 80

signal planet_release

var pivoting := false
var mouse_x:int = 0
var mouse_y:int = 0
var planet_pivoting := false
var camera_move_speed_scalar:float = 1
var min_zoom:float = 0
var max_zoom:float = 1000
var camera_held := false
var camera:Camera3D

func  _ready():
	camera = $Camera3D as Camera3D
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if camera_held:
		return
	
	var dir = Vector3.ZERO
	
	# TODO: Change pan to move pivot point
	# Camera Pan
	if not planet_pivoting:
		if Input.is_action_pressed("camera_pan_left"):
			dir += Vector3(-1,0,0)
		if Input.is_action_pressed("camera_pan_right"):
			dir += Vector3(1,0,0)
		if Input.is_action_pressed("camera_pan_forward"):
			dir += Vector3(0,0,-1)
		if Input.is_action_pressed("camera_pan_back"):
			dir += Vector3(0,0,1)
		dir = dir.normalized()
	
		$Camera3D.position = $Camera3D.position.move_toward(dir + $Camera3D.position, delta * camera_pan_speed * camera_move_speed_scalar)
	
	var rotate_dir = 0
	if Input.is_action_pressed("rotate_camera_clockwise"):
		rotate_dir -= 1
	if Input.is_action_pressed("rotate_camera_counterclockwise"):
		rotate_dir += 1
	
	rotate_object_local(Vector3.UP, rotate_dir*PI/3*delta)
	
func _input(event):
	if camera_held and not pivoting:
		return
	# Camera Zoom
	if event.is_action_released("camera_zoom_in") and $Camera3D.position.y > min_zoom:
		$Camera3D.position.y -= camera_zoom_speed * camera_move_speed_scalar
		$Camera3D.position.y = clamp($Camera3D.position.y, min_zoom, max_zoom)
	if event.is_action_released("camera_zoom_out") and $Camera3D.position.y < max_zoom:
		$Camera3D.position.y += camera_zoom_speed * camera_move_speed_scalar
		
		if planet_pivoting and $Camera3D.position.y > max_planet_zoom:
			camera_move_speed_scalar = 1
			new_pivot(global_position)
		$Camera3D.position.y = clamp($Camera3D.position.y, min_zoom, max_zoom)
	
	# TODO: Change pivot point to mouse location
	# Camera Pivot
	if event.is_action_pressed("camera_pivot"):
		pivoting = true
	if event.is_action_released("camera_pivot"):
		pivoting = false
		
	if pivoting and event is InputEventMouseMotion:
		var rotation_axis = Vector3(-1*event.relative.y, 0, event.relative.x).normalized()
		rotate_object_local(
			rotation_axis,
			event.relative.length_squared() * camera_sens * PI / 360
			)

func _on_planet_selected(planet:Planet):
	planet_release.emit(planet_release)
	camera_move_speed_scalar = 0.1
	min_zoom = planet.get_rad() * 1.1
	reparent(planet.body, false)
	planet_pivoting = true
	
	position = Vector3.ZERO
	snap_camera()
	$Camera3D.position.y = clamp(planet.planet_size * 5, min_zoom, $Camera3D.position.y if $Camera3D.position.y<max_planet_zoom*.5 else max_planet_zoom*.5)
	planet_release.connect(Callable(planet, "_on_planet_release"))

func snap_camera():
	$Camera3D.position = Vector3(0, $Camera3D.position.y, 0)


func new_pivot(pivot_point: Vector3):
	planet_release.emit(planet_release)
	min_zoom = 0
	var cam_pos = $Camera3D.global_position
	global_position = pivot_point
	$Camera3D.global_position = cam_pos
	reparent(get_tree().current_scene)


func go_to_star(keep_pos:bool = true):
	camera_move_speed_scalar = 1
	planet_pivoting = false
	new_pivot(Vector3.ZERO)
	min_zoom = 50
	if not keep_pos:
		snap_camera()
		$Camera3D.position.y = 284


func _on_star_star_select():
	go_to_star(false)


func _on_ui_hold_camera():
	camera_held = true


func _on_ui_stop_hold_camera():
	camera_held = false
