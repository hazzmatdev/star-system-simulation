extends Node3D

var colliding = false
var mesh:BoxMesh
var parent_planet:Planet
var camera:Camera3D
var offset:float
const READY_PLACE_COLOR = Color(0.169, 0.255, 0.761, 0.604)
const COLLIDING_COLOR = Color(0.69, 0.09, 0.141, 0.604)

# Called when the node enters the scene tree for the first time.
func _ready():
	mesh = $MeshInstance3D.mesh
	camera = get_viewport().get_camera_3d()
	offset = scale.z / 2
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Sep func so i can mess around here later and keep this
	move_hack()
	
	
func _on_area_3d_area_entered(area:Area3D):
	if area.get_parent().is_in_group("structure"):
		colliding = true 
		var mat = mesh.material as StandardMaterial3D
		mat.albedo_color = COLLIDING_COLOR
		mat.emission = COLLIDING_COLOR
		mat.emit_changed()


func _on_area_3d_area_exited(area:Area3D):
	if area.get_parent().is_in_group("structure"):
		colliding = false 
		var mat = mesh.material as StandardMaterial3D
		mat.albedo_color = READY_PLACE_COLOR
		mat.emission = READY_PLACE_COLOR
		mat.emit_changed()


func move_hack():
	# Clamp placer to surface of planet, this is a bit of a hack and needs to be changed later
	var screen_point := get_viewport().get_mouse_position()
	# set the cooridinates in the world to be the closest to the camera the placer could be
	var close = camera.project_position(screen_point, camera.position.y-(parent_planet.get_rad()))
	# Change the cooridantes to be local to the planet
	close = parent_planet.body.to_local(close)
	# Clamp the position to the planets surface
	position = close.limit_length(parent_planet.get_rad())
	#var axis_up = -position.direction_to(parent_planet.body.position)
	var axis_up = parent_planet.body.position.direction_to(position)
	# So this is just a circle tangent but im too tired to figure out the math
	# should be easy tho
	var focus_point = parent_planet.body.global_position
	look_at(focus_point, axis_up)

func find_angle():
	pass
	# So this is just a circle tangent but im too tired to figure out the math
	# should be easy tho
	#var focus_y
	#var focus_x
	#var focus_z
	#
	#if is_zero_approx(position.y):
		#focus_y = position + Vector3.UP
	#elif position.y > 0:
		#focus_y = Vector3.UP * parent_planet.get_rad_squared() / position.y
	#else:
		#focus_y = Vector3.DOWN * parent_planet.get_rad_squared() / position.y
	#
	#if is_zero_approx(position.x):
		#focus_x = position + Vector3.RIGHT
	#elif position.x > 0:
		#focus_x = Vector3.RIGHT * parent_planet.get_rad_squared() / position.x
	#else:
		#focus_x = Vector3.LEFT * parent_planet.get_rad_squared() / position.x
		#
	#if is_zero_approx(position.z):
		#focus_z = position + Vector3.FORWARD
	#elif position.z > 0:
		#focus_z = Vector3.FORWARD * parent_planet.get_rad_squared() / position.z
	#elif position.z < 0:
		#focus_z = Vector3.BACK * parent_planet.get_rad_squared() / position.z
		#
	#rotation = Vector3(position.angle_to(focus_x), position.angle_to(focus_y), position.angle_to(focus_z))
	#focus_vis.position = focus_y
	#axis_vis.position = axis_up * parent_planet.get_rad() * 1.1
