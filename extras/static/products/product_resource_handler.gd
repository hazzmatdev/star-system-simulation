extends Resource

@export var product_dict = {}
const path = "res://extras/static/products/products_base.tres"

func lookup_or_null(product_name:String):
	if product_name in product_dict:
		return product_dict[product_name]
	else:
		return null


func add_product(p_name, p_fam, p_rank, p_dens, p_tip=""):
	# Assumes the product is valid, keep the logic here dumb
	var new_product = {
		"family": p_fam,
		"rank": p_rank,
		"density": p_dens, # Density is in Kg/m^3
		"tooltip": p_tip,
	}
	
	product_dict[p_name] = new_product
	save_product()
	return { p_name: new_product }


func remove_product(p_name:String) -> bool:
	if p_name in product_dict:
		product_dict.erase(p_name)
		save_product()
		return true
	return false


func update_product(p_name, property, new_value) -> bool:
	if p_name in product_dict:
		product_dict[p_name][property] = new_value
		save_product()
		return true
	return false


func save_product() -> void:
		var error = ResourceSaver.save(self)
		assert(error == OK)
		emit_changed()
