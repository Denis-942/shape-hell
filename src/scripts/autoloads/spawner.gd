extends Node
class_name Spawner

#signal spawning_finished

static var _coin_drop_scene: PackedScene = preload("res://src/scenes/items/coin_drop.tscn")
static var _ammo_drop_scene: PackedScene = preload("res://src/scenes/items/ammo_drop.tscn")

var data: SpawnerData

var level := Level.new()

var spawn_parent: Node
var _active: bool
var _timer: float
var _spawned_nodes_count: int = 0
var _spawn_count: int = 0


func _init(spawner_data: SpawnerData) -> void:
	data = spawner_data.duplicate()
	_timer = 0.0
	spawn_parent = Game.inst.entity_holder
	
	Game.inst.spawner_holder.add_child(self)


func _process(delta: float) -> void:
	if _spawn_count >= data.total_spawn_amount:
		print("spawned %d, spawning finished" % _spawn_count)
		#spawning_finished.emit()
		queue_free()
	if not _active or _spawned_nodes_count >= data.spawn_limit:
		return
	_timer -= delta
	if _timer > 0.0:
		return
	for x: int in data.spawn_amount:
		if _spawned_nodes_count >= data.spawn_limit or _spawn_count >= data.total_spawn_amount:
			return
		_spawn()
		_spawn_count += 1


func activate(reset_timer: bool = false) -> void:
	_active = true
	if reset_timer:
		_timer = data.spawn_interval

func deactivate(reset_timer: bool = false) -> void:
	_active = false
	if reset_timer:
		_timer = data.spawn_interval

func is_active() -> bool:
	return _active


func _spawn() -> void:
	var scene: Node3D = data.spawn_scene.instantiate()
	scene.tree_exiting.connect(func() -> void:
		_spawned_nodes_count -= 1
		)
	scene.position = _get_random_position()
	spawn_parent.add_child(scene)
	_spawned_nodes_count += 1
	if scene is Enemy:
		var enemy := scene as Enemy
		enemy.level.set_value(level.value())
	#print(scene)
	_timer = data.spawn_interval


static func spawn(packed_scene: PackedScene, pos: Vector3, parent: Node) -> void:
	var object := packed_scene.instantiate() as Node3D
	object.position = pos
	parent.add_child.call_deferred(object)

static func spawn_weapon(weapon_data: WeaponData, pos: Vector3) -> void:
	var weapon := weapon_data.create_item_instance()
	weapon.position = pos
	Game.inst.item_holder.add_child(weapon)


static func spawn_coin(amount: int, pos: Vector3) -> void:
	var coin := _coin_drop_scene.instantiate() as CoinDrop
	coin.position = pos
	coin.amount = amount
	Game.inst.item_holder.add_child(coin)


static func spawn_ammo(amount: int, type: Game.AmmoType, weight: Game.AmmoWeight, pos: Vector3) -> void:
	var ammo := _ammo_drop_scene.instantiate() as AmmoDrop
	ammo.position = pos
	ammo.amount = amount
	ammo.type = type
	ammo.weight = weight
	Game.inst.item_holder.add_child(ammo)


func _get_random_position() -> Vector3:
	var dir_x := (randf() * 2.0) - 1.0
	var dir_z := (randf() * 2.0) - 1.0
	var dir := Vector3(dir_x, 0, dir_z).normalized()
	var pos: Vector3 = dir * (randf() * (data.spawn_radius / 2.0))
	return data.spawn_position + pos
