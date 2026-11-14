extends Weapon
class_name RangedWeapon


signal ammo_amount_changed(new_amount: int)

@export var projectile_scene: PackedScene = preload("res://src/scenes/projectiles/basic_bullet.tscn")

var _shoot_timer: float = 0.0
var _shooting: bool = false
var _reloading: bool = false

var _bullet_queue: Array[int]

func _ready() -> void:
	_bullet_queue.resize(512)
	_bullet_queue.fill(-1)
	#_rps = data.rpm / 60.0
	#_firerate = 1.0 / _rps
	#data.rpm_changed.connect(func(rpm: int) -> void:
		#_rps = rpm / 60.0
		#_firerate = 1.0 / _rps
		#)
	#Engine.max_fps = 5


func _process(delta: float) -> void:
	if _shoot_timer > 0.0:
		_shoot_timer -= delta
	if _shooting:
		_keep_shooting()
	
	for index: int in _bullet_queue.size():
		if _bullet_queue[index] == -1:
			continue
		if Time.get_ticks_msec() >= _bullet_queue[index]:
			_fire()
			_decrement_ammo()
			_bullet_queue[index] = -1


func shoot_start() -> void:
	if data.ammo == 0:
		@warning_ignore("missing_await")
		reload()
	if not _can_shoot():
		return
	_shooting = true
	if _shoot_timer <= 0.0:
		#_shoot_timer = 0.0 + data.get_fire_delay()
		_shoot()

func shoot_end() -> void:
	_shooting = false


func _keep_shooting() -> void:
	if data.ammo == 0:
		@warning_ignore("missing_await")
		reload()
	if not _can_shoot():
			return
	while _shoot_timer <= 0.0:
		_shoot()


func _get_dir() -> Vector3:
	var spread := randf_range(-data.spread_angle / 2.0, data.spread_angle / 2.0)
	return -global_basis.z.rotated(Vector3.UP, deg_to_rad(spread))

func _queue_bullet(timestamp: float) -> void:
	var i := 0
	while _bullet_queue[i] != -1:
		i += 1
	_bullet_queue[i] = Time.get_ticks_msec() + int(timestamp * 1000.0)

func _shoot() -> void:
	if data.is_single_fire():
		while _can_shoot():
			#_fire()
			_fire()
			_decrement_ammo()
			#data.ammo -= 1
			_shoot_timer += data.get_fire_delay()
	elif data.is_burst_fire():
		while _can_shoot():
			var bullets_count: int = mini(data.get_burst_count(), data.ammo)
			for count: int in bullets_count:
				if data.ammo <= 0:
					break
				#_fire()
				_queue_bullet(count * data.get_burst_interval())
				
					#if x != data.get_burst_count():
						#await Utils.delay_s(data.get_burst_interval())
						#await get_tree().create_shoot_timer(data.get_burst_interval()).timeout
			_shoot_timer += data.get_fire_delay() + data.get_burst_time()
	elif data.is_shotgun():
		while _can_shoot():
			for count: int in data.get_shot_count():
				#_fire()
				_fire()
				#if x != data.get_burst_count():
					##await Utils.delay_s(data.get_burst_interval())
					#await get_tree().create_shoot_timer(data.get_burst_interval()).timeout
			_decrement_ammo()
			_shoot_timer += data.get_fire_delay()


func _fire() -> void:
	var dir := _get_dir()
	var pos: Vector3 = global_position + (dir * randf())
	var damage: float = data.damage.scaled
	var params := ProjectileFireParameters.new(
		pos,
		dir,
		data.projectile_velocity,
		data.projectile_range,
		damage,
		data.pierce,
	)
	ProjectileSystem.fire_projectile(params)
	ammo_amount_changed.emit(data.ammo)


func reload() -> void:
	if data.ammo == data.max_ammo or _reloading:
		return
	# INFO if player doesnt have ammo of needed type and weight, return
	if Game.inst.player.get_inventory().get_ammo(data.ammo_type, data.ammo_weight) == 0:
		return
	_reloading = true
	await get_tree().create_timer(data.reload_time).timeout
	var ammo_needed: int = data.max_ammo - data.ammo
	# INFO if ammo in reserve is less than needed ammo, return the reserve
	var ammo_added: int = mini(Game.inst.player.get_inventory().get_ammo(data.ammo_type, data.ammo_weight), ammo_needed)
	
	data.ammo += ammo_added
	Game.inst.player.get_inventory().remove_ammo(ammo_added, data.ammo_type, data.ammo_weight)
	_reloading = false
	ammo_amount_changed.emit(data.ammo)
	#print("ammo: %d (%d added)" % [data.ammo, ammo_added])


func _can_shoot() -> bool:
	return _shoot_timer <= 0.0 and data.ammo > 0 and not _reloading


func _decrement_ammo() -> void:
	data.ammo -= 1
	ammo_amount_changed.emit(data.ammo)
