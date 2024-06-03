extends Control

@export var planetary_placer:PackedScene
var planet:Planet

func _on_place_structure_pressed():
	var placer = planetary_placer.instantiate()
	placer.parent_planet = planet
	get_viewport().get_camera_3d().get_parent_node_3d().add_child(placer)
	hide()
	
func _on_panel_container_mouse_entered():
	mouse_entered.emit()


func _on_panel_container_mouse_exited():
	mouse_exited.emit()
