extends Control
class_name Tooltip

var tooltip_scene: PackedScene

enum PositionType {
	RELATIVE,
	#ABSOLUTE,
}

@export var position_type: PositionType = PositionType.RELATIVE

@export var auto_position: bool = true
@export var target: Control
@export var offset := Vector2.ZERO



func _ready() -> void:
	visibility_changed.connect(func() -> void:
		set_process(visible)
		)
	hide()


func _process(_delta: float) -> void:
	if not auto_position or target == null:
		return
	position = target.global_position + offset
