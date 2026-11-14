@tool
extends Resource
class_name WeaponData

enum Type {
	SINGLE,
	BURST,
	SHOTGUN,
}

@export var weapon_name: String:
	get:
		return weapon_name
	set(value):
		weapon_name = value
		if _auto_weapon_id:
			weapon_id = weapon_name.to_snake_case()
@export var _auto_weapon_id: bool = true:
	get:
		return _auto_weapon_id
	set(value):
		_auto_weapon_id = value
		if _auto_weapon_id:
			weapon_id = weapon_name.to_snake_case()
		
## @experimental
@export var weapon_id: StringName

@export var _fire_type: Type = Type.SINGLE

@export var rarity: Game.Rarity


@export_subgroup("Single Fire", "_single_")
@export var _single_rpm: int = 60:
	get:
		return _single_rpm
	set(value):
		if _single_rpm == value:
			return
		_single_rpm = value
		_single_rps = _single_rpm / 60.0
		_single_fire_delay = 1.0 / (_single_rpm / 60.0)

@export var _single_rps: float = 1.0:
	get:
		return _single_rps
	set(value):
		if is_equal_approx(value, _single_rps):
			return
		_single_rps = value
		_single_rpm = int(_single_rps * 60)
		_single_fire_delay = 1.0 / _single_rps

@export var _single_fire_delay: float = 1.0:
	get:
		return _single_fire_delay
	set(value):
		if is_equal_approx(value, _single_fire_delay):
			return
		_single_fire_delay = value
		_single_rpm = int((1.0 / _single_fire_delay) * 60.0)
		_single_rps = 1.0 / _single_fire_delay


@export_subgroup("Burst Fire", "_burst_")
@export var _burst_fire_delay: float = 1.0:
	get:
		return _burst_fire_delay
	set(value):
		_burst_fire_delay = value
		_burst_rps = _burst_count / (get_burst_time() + _burst_fire_delay)
		_burst_rpm = int(_burst_rps * 60.0)

@export var _burst_count: int = 1:
	get:
		return _burst_count
	set(value):
		_burst_count = value
		_burst_rps = _burst_count / (get_burst_time() + _burst_fire_delay)
		_burst_rpm = int(_burst_rps * 60.0)

@export var _burst_interval: float = 0.1:
	get:
		return _burst_interval
	set(value):
		_burst_interval = value
		_burst_rps = _burst_count / (get_burst_time() + _burst_fire_delay)
		_burst_rpm = int(_burst_rps * 60.0)

@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY)
var _burst_rpm: int
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY)
var _burst_rps: float


@export_subgroup("Shotgun Fire", "_shotgun_")
@export var _shotgun_fire_delay: float = 1.0:
	get:
		return _shotgun_fire_delay
	set(value):
		_shotgun_fire_delay = value
		_shotgun_rps = 1.0 /  _shotgun_fire_delay
		_shotgun_rpm = int(_shotgun_rps * 60.0)

@export var _shotgun_shot_count: int = 1:
	get:
		return _shotgun_shot_count
	set(value):
		_shotgun_shot_count = value
		_shotgun_rps = 1.0 / _shotgun_fire_delay
		_shotgun_rpm = int(_shotgun_rps * 60.0)


@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY)
var _shotgun_rpm: int
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY)
var _shotgun_rps: float


var rpm: int:
	get:
		if is_single_fire():
			return _single_rpm
		elif is_burst_fire():
			return _burst_rpm
		elif is_shotgun():
			return _shotgun_rpm
		else:
			return -1
	set(_value):
		return

@export var damage: ScalableValue
@export var ammo_type: Game.AmmoType
@export var ammo_weight: Game.AmmoWeight
@export var max_ammo: int
@export var reload_time: float = 1.0
@export var pierce: int = 1
@export var projectile_range: float = 1.0
@export var projectile_velocity: float = 1.0
@export var spread_angle: float = 0.0
@export var weapon_scene: PackedScene
@export var item_scene: PackedScene

var level := Level.new()
var ammo: int

#var _equipped: bool = false
var _weapon_instance: Node3D


func _init() -> void:
	level.changed.connect(func(new_value: int) -> void:
		damage.scalar = new_value
		)
	await Utils.delay_frame()
	assert(damage != null)
	damage.set_scaling_func(func(b: float, l: int) -> float:
		return b * (1.0 + (l - 1) * 0.1)
		)


func get_weapon_instance() -> Weapon:
	var weapon := weapon_scene.instantiate() as Weapon
	weapon.data = self
	return weapon

func get_item_instance() -> WeaponDrop:
	var item := item_scene.instantiate() as WeaponDrop
	item.data = self
	return item


func create_item_instance() -> WeaponDrop:
	var item := item_scene.instantiate() as WeaponDrop
	item.data = duplicate()
	item.data.damage = damage.duplicate()
	item.data.level.set_value(level.value())
	item.data.ammo = max_ammo
	#item.data.level.set_value(level.value())
	return item

func equip() -> Weapon:
	var weapon := weapon_scene.instantiate() as Weapon
	weapon.data = self
	#_equipped = true
	_weapon_instance = weapon
	return weapon

func unequip() -> Weapon:
	#_equipped = false
	_weapon_instance.queue_free()
	_weapon_instance = null
	return null


#func get_fire_delay() -> float:
	#if not is_burst():
		#return 1.0 / _single_rpm / 60.0
	#else:
		#var burst_time: float = (_burst_count - 1) * burst_shot_interval
		#return _burst_count / burst_time * 60.0

func get_fire_delay() -> float:
	if is_single_fire():
		return _single_fire_delay
	elif is_burst_fire():
		return _burst_fire_delay
	else:
		return _shotgun_fire_delay


func is_single_fire() -> bool:
	return _fire_type == Type.SINGLE

func is_burst_fire() -> bool:
	return _fire_type == Type.BURST

func is_shotgun() -> bool:
	return _fire_type == Type.SHOTGUN


func get_shot_count() -> int:
	return _shotgun_shot_count

func get_burst_count() -> int:
	return _burst_count

func get_burst_interval() -> float:
	return _burst_interval


func get_burst_time() -> float:
	return (_burst_count - 1) * _burst_interval
