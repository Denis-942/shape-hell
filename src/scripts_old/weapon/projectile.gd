#@abstract
extends MeshInstance3D
class_name Projectile

#var _damage: float
#var _max_range: float
#var _velocity: float
#var _direction: Vector3
#var __origin_point: Vector3
#var __fired: bool = false
#var __initialized: bool = true # normally false
#var __index: int
