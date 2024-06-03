extends Node3D

var colliding = false
var mesh:BoxMesh
var parent_planet:Planet
var camera:Camera3D
var camera_pivot:Node3D
var offset:float
var body:Node3D
var screen_point:Vector2
var screen_center:Vector2
var world_point:Vector3
var theta:float
var distance:float
var zenith: float
var longitude: float
const READY_PLACE_COLOR = Color(0.169, 0.255, 0.761, 0.604)
const COLLIDING_COLOR = Color(0.69, 0.09, 0.141, 0.604)

# Called when the node enters the scene tree for the first time.
func _ready():
	mesh = $Body/MeshInstance3D.mesh
	camera = get_viewport().get_camera_3d()
	camera_pivot = camera.get_parent_node_3d()
	offset = scale.z / 2
	body = $Body
	
	body.position.y = parent_planet.get_rad()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	screen_point = get_viewport().get_mouse_position()
	screen_center = Vector2(get_viewport().get_visible_rect().size.x/2,get_viewport().get_visible_rect().size.y/2)
	var norm_distance = screen_center.distance_to(screen_point) / screen_center.x
	#var h = clamp(norm_distance * camera.position.y * tan(deg_to_rad(camera.fov / 2)),0,parent_planet.get_rad())
	#h = sqrt(parent_planet.get_rad_squared() - h**2)
	#print(parent_planet.get_rad_squared())
	#print(h**2)
	#print(sqrt(parent_planet.get_rad_squared() - h**2))
	world_point = camera.project_position(screen_point, camera.position.y - parent_planet.get_rad())
	#world_point = camera.project_position(screen_point, camera.position.y - h)
	world_point = camera_pivot.to_local(world_point)
	theta = -screen_center.angle_to_point(screen_point)
	distance = (Vector3.UP * parent_planet.get_rad()).distance_to(world_point)
	#distance = (Vector3.UP * h).distance_to(world_point)
	if is_equal_approx(distance, 0):
		zenith = 0
	else:
		zenith = atan(parent_planet.get_rad()/distance)
		
	rotation = Vector3(0,theta,zenith-PI/2)
	
	var pos_on_planet = parent_planet.body.to_local(body.global_position)
	var sgn = pos_on_planet.x / abs(pos_on_planet.x) if pos_on_planet.x != 0 else 1
	longitude = sgn * acos(pos_on_planet.z/sqrt(pos_on_planet.z**2 + pos_on_planet.x**2)) if pos_on_planet.x != 0 or pos_on_planet.z != 0 else 0 
	
	if pos_on_planet.y < 0:
		body.rotation = Vector3(0,-longitude-theta+camera_pivot.rotation.y,0)
	else:
		body.rotation = Vector3(0,longitude-theta-camera_pivot.rotation.y,0)
	
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

