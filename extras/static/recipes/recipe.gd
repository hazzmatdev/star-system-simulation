extends Object

class_name Recipe

signal recipe_exist(val:bool)

var base_recipes = preload("res://extras/static/recipes/recipes_base.tres")

var recipe_name: String
var recipe_time: float
var recipe_energy: int
var input: Array[Product] # theres a thought about changing these to dictionaries, could be easier to handle
var output: Array[Product] 
var tooltip: String

# Dictionary pattern
#{
		#"energy_cost": r_energy, # negative energy implies energy generation
		#"time": r_time,
		#"input": r_input,
		#"output": r_output,
		#"tooltip": r_tip,
#}

#input and output dicts should be formatted like:
	#{
	#	"[PRODUCT_NAME]":COUNT,
	#	...
	#}
# empty dicts are allowed and imply either resource gathering or energy generation
func _init(r_name):
	recipe_name = r_name
	var recipe_dict = base_recipes.lookup_or_null(recipe_name)
	
	if recipe_dict and Recipe.check_valid_dict(recipe_dict):
		recipe_time = recipe_dict["time"]
		recipe_energy = recipe_dict["energy_cost"]
		# If a product used in the recipe doesn't exist, the entire recipe should be discarded
		for i in recipe_dict["input"]:
			if not _add_input(i, recipe_dict["input"][i]):
				recipe_exist.emit(false)
				free()
				return
		for o in recipe_dict["output"]:
			if not _add_output(o, recipe_dict["output"][o]):
				recipe_exist.emit(false)
				free()
				return
		recipe_exist.emit(true)
	else:
		recipe_exist.emit(false)
		free()


func _add_input(new_in, count=0) -> bool:
	if new_in is Product:
		if new_in.is_valid() and new_in.units > 0:
			input.append(new_in)
			return true
	elif new_in is String:
		var new_prod = Product.new(new_in, count)
		if new_prod:
			input.append(new_prod)
			return true
	return false


func _add_output(new_out, count=0) -> bool:
	if new_out is Product:
		if new_out.is_valid() and new_out.units > 0:
			output.append(new_out)
			return true
	elif new_out is String:
		var new_prod = Product.new(new_out, count)
		if new_prod:
			output.append(new_prod)
			return true
	return false


func is_valid() -> bool:
	# Checks if the recipe is valid starting with the least intensive checks
	
	# All recipes must take some amount of time
	if recipe_time <= 0:
		return false
	
	# Check if any input is invalid
	for prod in input:
		if not prod.is_valid():
			return false
	
	# Check if any output is invalid
	for prod in output:
		if not prod.is_valid():
			return false
	
	return true


func generates_energy() -> bool:
	if recipe_energy < 0:
		return true
	return false


func is_raw() -> bool:
	# Resource collection (like mining) is determined if the recipe has no input. This may change
	if input.size() == 0:
		return true
	return false


func create_recipes_from_json():
	pass


static func check_valid_dict(dict:Dictionary):
	if dict.has_all(["energy_cost", "time", "input", "output", "tooltip"]):
		# can just extend the last if to include this via short circuit eval, but w/e it got too long
		if dict["input"] is Dictionary and dict["output"] is Dictionary:
			return true
	return false
