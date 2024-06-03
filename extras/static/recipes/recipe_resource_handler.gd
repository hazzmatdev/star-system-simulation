extends Resource

@export var recipe_dict = {}


func lookup_or_null(recipe_name:String):
	if recipe_name in recipe_dict:
		return recipe_dict[recipe_name]
	else:
		return null

#input and output dicts should be formatted like:
	#{
	#	"[PRODUCT_NAME]":COUNT,
	#	...
	#}
# empty dicts are allowed and imply either resource gathering or
# energy generation

func add_recipe(r_name, r_energy, r_time, r_input={}, r_output={}, r_tip=""):
	# Assumes the recipe is valid, keep the logic here dumb
	var new_recipe = {
		"energy_cost": r_energy, # negative energy implies energy generation
		"time": r_time,
		"input": r_input,
		"output": r_output,
		"tooltip": r_tip,
	}
	recipe_dict[r_name] = new_recipe
	save_recipe()
	return { r_name: new_recipe }


func remove_recipe(r_name:String) -> bool:
	if r_name in recipe_dict:
		recipe_dict.erase(r_name)
		save_recipe()
		return true
	return false


func update_recipe(r_name, property, new_value) -> bool:
	if r_name in recipe_dict:
		recipe_dict[r_name][property] = new_value
		save_recipe()
		return true
	return false

func save_recipe() -> void:
		var error = ResourceSaver.save(self)
		assert(error == OK)
		emit_changed()
