extends Object

class_name Product

enum PRODUCT_FAMILY {
	DEFAULT,
	RAW_IRON,
	RAW_COPPER,
	IRON,
	COPPER,
	CARBON, # might change name
	GLASS,
	WIRE,
	FLUX,
	CIRCUIT,
	SILICA,
	
}

const KG_PER_UNIT = 100
var product_name: String
var product_family: PRODUCT_FAMILY
var product_rank: int
var product_density: float # Kg/m^3
var tooltip: String
var units: int

var base_products = preload("res://extras/static/products/products_base.tres")

signal product_exist(val:bool)
# dict pattern 
 #{
	 #"[PRODUCT_NAME]": {
	 	#"family": "DEFAULT",
	 	#"rank": 0,
	 	#"density": 0,
	 	#"tooltip": "",
	 #}, ...
 #}

func _init(p_name:String, p_unit=0) -> void:
	# First we find if the product already exists in the resource using the name as the key
	product_name = p_name
	var product_dict = base_products.lookup_or_null(p_name)
	
	# Then if it does we pass back a new instance of that using the info 
	# from the resource and the given units
	if product_dict and Product.check_valid_dict(product_dict):
		product_family = PRODUCT_FAMILY[product_dict["family"]]
		product_rank = product_dict["rank"]
		product_density = product_dict["density"]
		tooltip = product_dict["tooltip"]
		units = p_unit
		product_exist.emit(true)
	else:
		product_exist.emit(false)
		free() # THIS MIGHT BE A VERY BAD IDEA LMAO


func _to_string() -> String:
	return product_name + (" %d Kg/Unit" % (product_density/KG_PER_UNIT))


func get_material_weight_string() -> String:
	return product_name + (", %f Kg" % snapped(KG_PER_UNIT*units, 0.01))


func get_material_weight_float() -> float:
	return KG_PER_UNIT*units


func get_units_from_given_weight(weight) -> float:
	return weight / KG_PER_UNIT


func is_valid() -> bool:
	# These are really the only 2 required bits valid data
	return product_density > 0 and product_family in PRODUCT_FAMILY


func to_dict() -> Dictionary:
	var product_dict = {
		product_name: {
			"family": product_family,
			"rank": product_rank,
			"density": product_density,
			"tooltip": tooltip,
			"units": units
		}
	}
	return product_dict

static func check_valid_dict(dict:Dictionary) -> bool:
	if dict.has_all(["family", "rank", "density", "tooltip"]):
		return true
	return false
