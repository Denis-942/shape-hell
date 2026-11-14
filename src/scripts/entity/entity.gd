extends CharacterBody3D
class_name Entity


signal health_changed(old_value: float, new_value: float)

enum HealthState {
	ALIVE,
	DYING,
	DEAD,
}

enum MoveState {
	IDLE,
	WALKING,
	SPRINTING,
}
var move_state := MoveState.IDLE
var level := Level.new()


@export var _max_health: ScalableValue:
	get:
		return _max_health
	set(value):
		_max_health = value
		#_health = min(_health, get_max_health())


var _health: float:
	get:
		return _health
	set(value):
		#if _health + value > _max_health:
			#print(_health + value)
			#value = _max_health - _health
		health_changed.emit(_health, value)
		_health = min(value, get_max_health())
		#if _health <= 0.0:
			#_health_state = HealthState.DEAD
			##_die()
		#else:
			#_health_state = HealthState.ALIVE
		#print(_health)

var _health_state: HealthState = HealthState.ALIVE


func _enter_tree() -> void:
	_max_health.set_scaling_func(func(b: float, l: int) -> float:
		return b * (1.0 + (l - 1) * 0.1)
		)
	_max_health.scalar = maxi(level.value(), 1)
	level.changed.connect(func(new_value: int) -> void:
		_max_health.scalar = maxi(new_value, 1)
		heal(get_max_health())
		#print("new level (%d) and scalar (%f) for %s" % [level.value(), _max_health.scalar, self])
		)


func _physics_process(delta: float) -> void:
	_handle_gravity(delta)
	move_and_slide()


func take_damage(amount: float) -> void:
	_take_damage(amount)


func _take_damage(amount: float) -> void:
	_health -= amount
	#print("taken %f dmg, health is now %f" % [amount, _health])
	if _health <= 0.0 and _health_state != HealthState.DEAD:
		_die()

func _die() -> void:
	_health_state = HealthState.DEAD
	queue_free()

func is_dead() -> bool:
	return _health <= 0.0

func heal(amount: float) -> void:
	_health = min(_health + amount, get_max_health())


func _handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += -pow(9.81, 2) * delta


func get_health() -> float:
	return _health

func get_max_health() -> float:
	var f: float = _max_health.scaled
	return f
