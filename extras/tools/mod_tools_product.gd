extends Control

signal product_created(val:bool, text:String)

var pos_float_only_regex := RegEx.new()
var int_regex := RegEx.new()
var old_dens = "1.0"
var old_rank = "0"
var base_products = preload("res://extras/static/products/products_base.tres")

func _ready():
	pos_float_only_regex.compile("^[0-9]*\\.?[0-9]*$")
	int_regex.compile("^-?[0-9]+$")
	var family_sel = %FamilySelector as OptionButton
	
	for family in Product.PRODUCT_FAMILY:
		family_sel.add_item(family, family_sel.item_count)


func _on_panel_container_mouse_entered():
	mouse_entered.emit()


func _on_panel_container_mouse_exited():
	mouse_exited.emit()


func _on_add_pressed():
	var fam_sel = %FamilySelector as OptionButton
	var p_name = %ProductName.text
	var p_fam = fam_sel.get_item_text(fam_sel.selected)
	var p_rank = int(%Rank.text)
	var p_dens = float(%Density.text)
	var p_tool = %Tooltip.text
	
	
	if valid_name():
		base_products.add_product(p_name,p_fam,p_rank,p_dens,p_tool)
		product_created.emit(true, p_name)
	#TODO: add shake animation if invalid add

func open_new_product():
	position = get_viewport().get_mouse_position()
	show()


func _on_cancel_pressed():
	product_created.emit(false)
	hide()


func valid_name():
	var product_name_edit = %ProductName as LineEdit
	if not product_name_edit.text:
		print("Product must have a name")
		return false
	if product_name_edit.text in base_products.product_dict:
		print("Product Name %s already registered" % product_name_edit.text )
		product_name_edit.add_theme_color_override(
			"font_color", Color(1, 0.239, 0.239))
		return false
	return true


func _on_product_name_text_changed(new_text):
	var product_name_edit = %ProductName as LineEdit
	if product_name_edit.has_theme_color_override("font_color") and new_text not in base_products:
		product_name_edit.remove_theme_color_override("font_color")


func _on_rank_text_changed(new_text):
	if int_regex.search(new_text):
		old_rank = new_text
	else:
		%Rank.text = old_rank
		%Rank.caret_column = %Rank.text.length()


func _on_density_text_changed(new_text):
	if pos_float_only_regex.search(new_text) and float(new_text) > 0:
		old_dens = new_text
	else:
		%Density.text = old_dens
		%Density.caret_column = %Density.text.length()

