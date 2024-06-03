extends Node3D

signal star_select

var body_pos := Vector3.ZERO
var star_select_ready := false

func _input(event):
	if star_select_ready and event.is_action_pressed("ui_click"):
		star_select.emit()


func _on_area_3d_mouse_entered():
	star_select_ready = true


func _on_area_3d_mouse_exited():
	star_select_ready = false
