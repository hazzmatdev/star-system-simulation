extends Button

class_name ObjectButton

var _obj_ref: Object


func set_object_ref(obj:Object):
	_obj_ref = obj
	if obj is CargoSource:
		text = obj.object_name
	else:
		text = "Unknown Object"


func get_object_ref() -> Object:
	return _obj_ref


func is_object_ref(other:Object) -> bool:
	return other == _obj_ref
