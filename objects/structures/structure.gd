extends CargoSource

class_name Structure

enum STRUCTURE_TYPES {
	EXTRACTOR, 
	SPACE_STATION,
	FURNACE,
	AUTOFAC, # <3 PKD
	POWER_STATION,
	
	}

@export var structure_type: STRUCTURE_TYPES
@export var recipes: Array[String]
# all structures generate a small amount of energy by existing to prevent soft locks
@export var trickle_charge: int

var current_recipe: Recipe

func set_active_recipe(recipe) -> bool:
	print(recipe)
	if recipe is String and recipe in recipes:
		current_recipe = Recipe.new(recipe)
		if current_recipe is Recipe:
			print("Current recipe for %s: %s set to %s" % [STRUCTURE_TYPES.keys()[structure_type], object_name, current_recipe.recipe_name])
			return true
	elif recipe is int and recipes.size() > recipe:
		current_recipe = Recipe.new(recipes[recipe])
		if current_recipe is Recipe:
			print("Current recipe for %s: %s set to %s" % [STRUCTURE_TYPES.keys()[structure_type], object_name, current_recipe.recipe_name])
			return true
	print("recipe not found")
	return false
