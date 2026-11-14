extends Resource
class_name ScalableValue


@export var base: Variant

var scalar: Variant

var scaled: Variant:
	get:
		return _scaling_func.call(base, scalar)
	set(_value):
		return

var _scaling_func: Callable


static func create(base_value: Variant, scalar_value: Variant, scaling_func: Callable) -> ScalableValue:
	var scalable_value := ScalableValue.new()
	scalable_value.base = base_value
	scalable_value.scalar = scalar_value
	scalable_value.set_scaling_func(scaling_func)
	return scalable_value


func set_scaling_func(scaling_func: Callable) -> void:
	if scaling_func.get_argument_count() != 2:
		push_error("Parameter 'scaling_func' (Callable) has to take 2 arguments (base_value, scalar)")
	_scaling_func = scaling_func
