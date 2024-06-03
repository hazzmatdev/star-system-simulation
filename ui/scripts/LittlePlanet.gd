extends Node2D

var orb_rads:float
var select_ready := false
var paused := false
var planet_name:String

signal planet_clicked


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not paused:
		transform = transform.rotated_local(orb_rads*delta)


func initialize(planet_scale:float, orb_dist:float, orb_speed:float, progress:float, pname:=''):
	$LittlePlanet.scale *= planet_scale
	$LittlePlanet.position.x = orb_dist
	orb_rads = -orb_speed
	rotate(progress * 2 * PI)
	planet_name = pname


func _input(event):
	if event.is_action_pressed("ui_click") and select_ready:
		print(planet_name + " ui clicked")
		planet_clicked.emit()
	if event.is_action_pressed("pause_planet_movement"):
		paused = not paused


func _on_area_2d_mouse_entered():
	select_ready = true


func _on_area_2d_mouse_exited():
	select_ready = false
