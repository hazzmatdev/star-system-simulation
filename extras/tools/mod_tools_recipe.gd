extends Control

enum OPEN_WINDOW {NONE,INPUT,OUPUT}

signal recipe_created(flag:bool, r_name:String)

var base_recipes = preload("res://extras/static/recipes/recipes_base.tres")
var base_products = preload("res://extras/static/products/products_base.tres")
var item_lister:HBoxContainer
var waiting_on_new = false
var win = OPEN_WINDOW.NONE
var inputs = {}
var outputs = {}
var pos_float_regex := RegEx.new()
var int_regex := RegEx.new()
var old_input_count = ""
var old_output_count = ""
var old_energy = ""
var old_time = ""


func _ready():
	pos_float_regex.compile("^[0-9]*\\.?[0-9]*$")
	int_regex.compile("^-?[0-9]*$")
	item_lister = $ItemLister as HBoxContainer
	var product_selector_in = %ExistingProductInput as OptionButton
	var product_selector_out = %ExistingProductOutput as OptionButton
	for prod in base_products.product_dict:
		product_selector_in.add_item(prod)
		product_selector_out.add_item(prod)


func _on_input_pressed():
	$RecipeInputs.visible = !$RecipeInputs.visible 
	$RecipeOutputs.hide()
	$ModToolsProduct.hide()
	win = OPEN_WINDOW.INPUT


func _on_output_pressed():
	$RecipeOutputs.visible = !$RecipeOutputs.visible 
	$RecipeInputs.hide()
	$ModToolsProduct.hide()
	win = OPEN_WINDOW.OUPUT


func _on_existing_product_item_selected(index):
	if index == 0:
		waiting_on_new = true
		$ModToolsProduct.show()
		# TODO: Should disable the add product button
	else:
		waiting_on_new = false
		$ModToolsProduct.hide()


func _on_mod_tools_product_product_created(val, text=""):
	var product_selector_in = %ExistingProductInput as OptionButton
	var product_selector_out = %ExistingProductOutput as OptionButton
	waiting_on_new = false
	if val:
		product_selector_in.add_item(text)
		product_selector_out.add_item(text)
		if win == OPEN_WINDOW.INPUT:
			product_selector_in.select(product_selector_in.item_count-1)
		elif win == OPEN_WINDOW.OUPUT:
			product_selector_out.select(product_selector_in.item_count-1)
		else:
			assert(false, "Neither input nor output open when product added. This shouldn't happen")
	else:
		# dont need to emit the selection change bc everything we want to do with that is already done
		product_selector_in.select(-1)
		product_selector_out.select(-1)


func _on_input_clear_pressed():
	%CountInput.text = ""
	old_input_count = ""
	var product_selector_in = %ExistingProductInput as OptionButton
	product_selector_in.select(-1)
	product_selector_in.item_selected.emit(-1)


func _on_output_clear_pressed():
	%CountOutput.text = ""
	old_output_count = ""
	var product_selector_out = %ExistingProductOutput as OptionButton
	product_selector_out.select(-1)
	product_selector_out.item_selected.emit(-1)


func _on_cancel_pressed():
	hide()
	recipe_created.emit(false)


func _on_count_input_text_changed(new_text):
	if int_regex.search(new_text) and int(new_text) >= 0:
		old_input_count = new_text
	else:
		%CountInput.text = old_input_count
		%CountInput.caret_column = %CountInput.text.length()


func _on_count_output_text_changed(new_text):
	if int_regex.search(new_text)  and int(new_text) >= 0:
		old_output_count = new_text
	else:
		%CountInput.text = old_output_count
		%CountInput.caret_column = %CountInput.text.length()


func _on_input_add_pressed():
	var prod_name = %ExistingProductInput.text
	var count = int(%CountInput.text)
	
	if prod_name in inputs:
		print("Product already in inputs, not added")
	elif base_products.lookup_or_null(prod_name) and count > 0:
		print("Adding %s to inputs with count: %d" % [prod_name, count])
		inputs[prod_name] = count
		print("Internal input list")
		print(inputs)
		var new_item_lister = item_lister.duplicate()
		var button = new_item_lister.get_child(3) as Button
		# Accessing via child index is very not robust but w/e ill go with this until it crashes smthing
		new_item_lister.get_child(0).text = str(count)
		new_item_lister.get_child(2).text = prod_name
		button.set_meta("prod_name", prod_name)
		button.set_meta("type", "Input")
		button.pressed.connect(
			Callable(self, "_on_remove_item_lister_pressed").bind(button)
		)
		%RecipeInputItems.add_child(new_item_lister)
		new_item_lister.show()
	_on_input_clear_pressed()


func _on_output_add_pressed():
	var prod_name = %ExistingProductOutput.text
	var count = int(%CountOutput.text)
	
	if prod_name in outputs:
		print("Product already in outputs, not added")
	elif base_products.lookup_or_null(prod_name) and count > 0:
		print("Adding %s to outputs with count: %d" % [prod_name, count])
		outputs[prod_name] = count
		print("Internal output list")
		print(outputs)
		var new_item_lister = item_lister.duplicate()
		var button = new_item_lister.get_child(3) as Button
		# Accessing via child index is very not robust but w/e ill go with this until it crashes smthing
		new_item_lister.get_child(0).text = str(count)
		new_item_lister.get_child(2).text = prod_name
		button.set_meta("prod_name", prod_name)
		button.set_meta("type", "Output")
		button.pressed.connect(
			Callable(self, "_on_remove_item_lister_pressed").bind(button)
		)
		%RecipeOutputItems.add_child(new_item_lister)
		new_item_lister.show()
	_on_output_clear_pressed()


func _on_remove_item_lister_pressed(button:Button):
	var prod_name = button.get_meta("prod_name")
	var io =  button.get_meta("type")
	if io == "Input":
		print("Input %s removed" % prod_name)
		inputs.erase(prod_name)
		print("Internal input list")
		print(inputs)
	elif io == "Output":
		print("Output %s removed" % prod_name)
		outputs.erase(prod_name)
		print("Internal output list")
		print(outputs)
	button.get_parent().queue_free()


func _on_energy_text_changed(new_text):
	if int_regex.search(new_text) and int(new_text) >= 0:
		old_energy = new_text
	else:
		%Energy.text = old_energy
		%Energy.caret_column = %Energy.text.length()


func _on_time_text_changed(new_text):
	if pos_float_regex.search(new_text)  and int(new_text) >= 0:
		old_time = new_text
	else:
		%Time.text = old_time
		%Time.caret_column = %Time.text.length()


func _on_add_pressed():
	var r_name = %RecipeName.text
	var r_energy = int(%Energy.text)
	var r_time = float(%Time.text)
	
	if valid(r_name, r_time):
		base_recipes.add_recipe(r_name,r_energy,r_time,inputs,outputs,%Tooltip.text)
		recipe_created.emit(true, r_name)
		print("%s added to recipes" % r_name)
		print(base_recipes.lookup_or_null(r_name))
		clear_all()
	else:
		# Shake and turn text red or something
		pass


func valid(r_name, r_time) -> bool:
	if not r_name:
		print("Recipe must have a name")
		return false
	if base_recipes.lookup_or_null(r_name):
		print("Recipe %s is already registered" % r_name)
		return false
	if r_time < 0 or is_equal_approx(r_time, 0):
		print("Time must be greater than 0")
		return false
	return true

func clear_all() -> void:
	%RecipeName.text = ""
	%Energy.text = "0"
	old_energy = "0"
	%Time.text = "0.0"
	old_time = "0.0"
	inputs = {}
	outputs = {}
	var listers = %RecipeOutputItems.get_children()
	listers.append_array(%RecipeInputItems.get_children())
	
	for lister in listers:
		if lister.name == "ItemLister":
			lister.queue_free()


func _on_mouse_entered():
	mouse_entered.emit()


func _on_mouse_exited():
	mouse_exited.emit()


