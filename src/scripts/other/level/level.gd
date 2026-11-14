extends RefCounted
class_name Level


signal changed(new_value: int)


var _value: int = 1


func value() -> int:
	return _value

func set_value(new_value: int) -> void:
	_value = new_value
	changed.emit(_value)

func increase(amount: int) -> void:
	set_value(_value + amount)

func increment() -> void:
	set_value(_value + 1)
