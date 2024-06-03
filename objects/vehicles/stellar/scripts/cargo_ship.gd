extends Pausable

class_name CargoShip

@export var max_velo: int
@export var accel: int
@export var destination: CargoSource
@export var source: CargoSource

signal reached_destination
var velo:float = 2
	
func initialize(dest: CargoSource, source_node: CargoSource, scalar = 1):
	destination = dest
	source = source_node
	scale = Vector3(scalar, scalar, scalar)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	if source:
		if "moons" in source.get_groups():
			reparent(source.get_parent_node_3d())
			
	var init_look = position.move_toward(destination.body.global_position, velo)
	if not init_look.is_equal_approx(position):
		look_at(global_position.direction_to(destination.body.global_position))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if paused:
		return
	
	if velo < max_velo:
		velo +=  accel * delta 
	else:
		velo = max_velo
	
	var next_pos = global_position.move_toward(destination.body.global_position, velo * delta)
	
	if not next_pos.is_equal_approx(global_position): 
		look_at(next_pos)
		global_position = next_pos
	if global_position.is_equal_approx(destination.body.global_position):
		reached_destination.emit()
	


func _on_reached_destination():
	# JESUS DOES THIS PRINT A LOT
	#print("Cargo from %s reached destination %s" % [source.object_name, destination.object_name])
	queue_free()
