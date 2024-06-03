extends CanvasLayer

@export var little_planet: PackedScene
@export var orbit_interval: float = 7

signal star_select
signal hold_camera
signal stop_hold_camera

var camera: Node3D
var select_star_ready := false
var selected_obj: CargoSource
var selected_secondary: CargoSource
var old_cargo_time_edit_text := "0.75"
var pos_float_only_regex := RegEx.new()
var min_cargo_time := 0.25 

# Called when the node enters the scene tree for the first time.
func _ready():
	pos_float_only_regex.compile("^[0-9]*\\.?[0-9]*$")


func _process(_delta):
	pass
	#if camera:
	#	$StarSystemOverview/SystemOrigin.rotation = camera.rotation.y
	
	
func _on_check_box_toggled(toggled_on:bool):
	get_tree().call_group("orbit_body", "toggle_orbit", toggled_on)


func make_planet_ui():
	var planets = get_tree().get_nodes_in_group("planets")
	planets.sort_custom(func(a,b):return a.orbit_distance < b.orbit_distance)
	%SystemOrigin/StarOverview.scale *= 10
	%SystemOrigin.position -= (planets.size()+1) * Vector2(orbit_interval,orbit_interval)
	for i in range(planets.size()):
		var planet = planets[i]
		var planet_clicker = little_planet.instantiate()
		planet_clicker.initialize(
			planet.scale.x * 4, 
			(i+1) * orbit_interval, 
			planet.orb_rads,
			planet.orbit_init_progress,
			planet.object_name
			)
		
		planet_clicker.planet_clicked.connect(
			Callable(planet, "_on_planet_clicker_planet_clicked")
		)
		%SystemOrigin.add_child(planet_clicker)


func populate_planet_list():
	var planets = get_tree().get_nodes_in_group("planets")
	var moons = get_tree().get_nodes_in_group("moons")
	add_planet_list_buttons(planets)
	add_planet_list_buttons(moons)


func add_planet_list_buttons(planets:Array):
	for planet in planets:
		var list_item = ObjectButton.new()
		list_item.set_object_ref(planet)
		list_item.mouse_entered.connect(
			Callable(self, "_on_ui_entered")
		)
		list_item.pressed.connect(
			Callable(self, "_on_cargolane_planet_select_toggled").bind(list_item.get_object_ref())
		)
		%PlanetList.add_child(list_item)


func _input(event):
	if select_star_ready and event.is_action_pressed("ui_click"):
		star_select.emit()
	if event.is_action_pressed("debug_tools"):
		$ModToolsRecipe.visible = not $ModToolsRecipe.visible
	if event.is_action_pressed("ui_cancel"):
		close_object_panel()
		$ModToolsRecipe.hide()


func open_object_panel(object:CargoSource):
	if %PlanetListContainer.visible:
		print("Panel open, editing secondary")
		_on_cargolane_planet_select_toggled(object)
		return
	selected_obj = object
	$ObjectPanel.show()
	if object is CargoSource:
		%ObjectName.text = object.object_name
		var l_items = %PlanetList.get_children()
		for item in l_items:
			item.show()
			if item.is_object_ref(object):
				item.hide()
	print("Opening object panel for %s" % %ObjectName.text)


func close_object_panel():
	print("Closed object panel")
	$ObjectPanel.hide()
	$CargoLanePanel.hide()
	%PlanetListContainer.hide()


func _on_star_selector_mouse_entered():
	select_star_ready = true


func _on_star_selector_mouse_exited():
	select_star_ready = false


func set_star_name(star_name:String):
	$StarNameContainer/StarName.text = star_name


func _on_ui_entered():
	hold_camera.emit()


func _on_ui_exited():
	stop_hold_camera.emit()


func _on_cargolane_button_toggled(toggled_on:bool):
	%PlanetListContainer.visible = toggled_on
	if not toggled_on:
		$CargoLanePanel.hide()


func _on_cargolane_planet_select_toggled(obj:CargoSource):
	selected_secondary = obj
	$CargoLanePanel.show()
	if selected_obj is CargoSource:
		%SourcePlanet.text = selected_obj.object_name
	%DestinationPlanet.text = obj.object_name


func _on_cargo_mode_select_item_selected(index:int):
	match index:
		0:
			%SendEveryInput.show()
			%SendOnCargoPercentInput.hide()
		1:
			%SendEveryInput.hide()
			%SendOnCargoPercentInput.show()


func _on_cargo_time_edit_text_changed(new_text:String):
	if pos_float_only_regex.search(new_text):
		old_cargo_time_edit_text = new_text
	else:
		%CargoTimeEdit.text = old_cargo_time_edit_text
		%CargoTimeEdit.caret_column = %CargoTimeEdit.text.length()


func _on_send_cargo_button_pressed():
	var mode_index = %CargoModeSelect.selected
	
	if not selected_obj or not selected_secondary:
		return
		
	match mode_index:
		0:
			var time = float(%CargoTimeEdit.text)
			if not (time >= min_cargo_time):
				return
			selected_obj.create_cargo_lane_timed(selected_secondary, time)
		1:
			selected_obj.create_cargo_lane_on_cargo_percent(selected_secondary)
	
	%PlanetListContainer.hide()
	$CargoLanePanel.hide()
	stop_hold_camera.emit()


func _on_create_structure_pressed():
	$CreateStructurePanel.visible = not $CreateStructurePanel.visible
	if $CreateStructurePanel.visible:
		$CreateStructurePanel.planet = selected_obj
	
