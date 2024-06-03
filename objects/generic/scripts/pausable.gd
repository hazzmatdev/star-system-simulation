extends Node3D

class_name Pausable

var paused := false

func _input(event):
	if event.is_action_pressed("pause_planet_movement"):
		paused = not paused
