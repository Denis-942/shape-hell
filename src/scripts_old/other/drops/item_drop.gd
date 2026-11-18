@abstract
extends RigidBody3D
class_name ItemDrop


@export var _mesh: MeshInstance3D

var _despawn_timer: float = 9999


func _ready() -> void:
	assert(_mesh != null, "The Mesh property of ItemDrop cannot be null")


func _process(delta: float) -> void:
	_mesh.rotate_y(delta * PI)
	_despawn_timer -= delta
	if _despawn_timer <= 0.0:
		queue_free()


@abstract
func collect() -> Variant
