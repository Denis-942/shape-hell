extends RefCounted
class_name ProjectileFireParameters

var damage: float
var pierce: int
var position: Vector3
var direction: Vector3
var velocity: float
var distance_limit: float


func _init(
	_position: Vector3,
	_direction: Vector3,
	_velocity: float,
	_distance_limit: float,
	_damage: float,
	_pierce: int
	) -> void:
	position = _position
	direction = _direction
	velocity = _velocity
	distance_limit = _distance_limit
	damage = _damage
	pierce = _pierce
