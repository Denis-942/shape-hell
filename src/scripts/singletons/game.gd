extends Node
class_name Game

const SAVE_LOAD_PATH := "user://data.cfg"
const SAVE_LOAD_PASSWORD := ""

signal started
signal stopped
signal paused
signal unpaused
#signal wave_changed(wave_number: int)
signal wave_started(wave_number: int)
signal wave_finished(wave_number: int)
signal enemy_died(enemy: Enemy)
signal player_died
signal enemy_kill_count_changed(new_value: int)
signal score_changed(new_value: int)
signal high_score_changed(new_value: int)
signal best_wave_changed(new_value: int)
signal inventory_opened
signal inventory_closed


@export var player: Player
@export var test_dummy: Entity
@export var entity_holder: Node
@export var item_holder: Node
@export var spawner_holder: Node
@export var projectile_holder: Node
@export var game_map: Node3D
@export var main_menu_camera: Node
@export var ui_canvas_root: CanvasLayer
@export var spawner_pos: Node3D # INFO TEMPORARY
@export var spawner_datas: Array[SpawnerData]

enum AmmoType {
	BULLET = 0,
	SHELL = 1,
}

enum AmmoWeight {
	LIGHT = 0,
	MEDIUM = 1,
	HEAVY = 2,
}


enum Rarity {
	COMMON = 0,
	UNCOMMON = 1,
	RARE = 2,
	EPIC = 3,
	LEGENDARY = 4,
}

const RARITY_COLORS: Dictionary[Rarity, Color] = {
	Rarity.COMMON: Color.LIGHT_BLUE,
	Rarity.UNCOMMON: Color.LIGHT_GREEN,
	Rarity.RARE: Color.DEEP_SKY_BLUE,
	Rarity.EPIC: Color.PURPLE,
	Rarity.LEGENDARY: Color.GOLD,
}

var weapon_datas: Array[WeaponData]
var starter_weapon_data := preload("res://src/resources/pistol_weapon_data.tres")
var test_weapon_data := preload("res://editor/test_weapon_data.tres")


static var inst: Game:
	get:
		return inst
	set(value):
		if inst != null and value != inst:
			push_error("Game Instance is already set up")
			return
		else:
			inst = value

var _playing: bool = false:
	get:
		return _playing
	set(value):
		_playing = value
		if _playing:
			started.emit()
		else:
			stopped.emit()
		get_tree().paused = not _playing or _paused
var _paused: bool = false:
	get:
		return _paused
	set(value):
		_paused = value
		if _paused:
			paused.emit()
		else:
			unpaused.emit()
		get_tree().paused = not _playing or _paused


var _enemy_kill_count: int:
	get:
		return _enemy_kill_count
	set(value):
		_enemy_kill_count = value
		enemy_kill_count_changed.emit(value)

var _player_death_count: int
	#get:
		#return _player_death_count
	#set(value):
		#_player_death_count = value

var _score: int:
	get:
		return _score
	set(value):
		_score = value
		score_changed.emit(_score)
		if _score > _high_score:
			_high_score = _score

var _high_score: int:
	get:
		return _high_score
	set(value):
		_high_score = value
		high_score_changed.emit(_high_score)

var _wave_number: int:
	get:
		return _wave_number
	set(value):
		_wave_number = value
		if _wave_number > _best_wave:
			_best_wave = _wave_number
		#wave_changed.emit(_wave_number)

var _best_wave: int:
	get:
		return _best_wave
	set(value):
		_best_wave = value
		best_wave_changed.emit(_best_wave)


var _wave_enemies_left: int:
	get:
		return _wave_enemies_left
	set(value):
		_wave_enemies_left = value
		if _wave_enemies_left == 0:
			wave_finished.emit(_wave_number)


func _enter_tree() -> void:
	inst = self
	enemy_died.connect(_on_enemy_died)
	player_died.connect(func() -> void:
		_player_death_count += 1
		)
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	_load_weapon_datas()
	_enemy_kill_count = 0
	_player_death_count = 0
	_high_score = 0
	_best_wave = 0

	_spawn_starter_weapon()

	_load_data()
	go_to_main_menu()

	wave_finished.connect(func(wave_number: int) -> void:
		print("finished wave %d" % wave_number)
		print("starting wave %d in 1 second...\n" % (wave_number + 1))
		await get_tree().create_timer(1.0).timeout
		_start_next_wave()
		)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_pause"):
		if is_playing():
			if not is_paused():
				pause()
			else:
				unpause()

	if Input.is_action_just_pressed("toggle_inventory"):
		if is_playing():
			if not is_paused():
				pause()
				inventory_opened.emit()
			else:
				unpause()
				inventory_closed.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit()


func start() -> void:
	_score = 0
	_enemy_kill_count = 0
	_kill_all_enemies()
	player.global_position = Vector3(0, 2.0, 0)
	#print.call_deferred(nodes.player.get_health())
	player.heal(player.get_max_health())
	_playing = true
	_paused = false
	start_wave(1)
	# NOTE temporary
	player.get_inventory().set_ammo(100, Game.AmmoType.BULLET, Game.AmmoWeight.LIGHT)


func start_wave(wave_number: int) -> void:
	print("starting wave %d" % wave_number)
	_wave_number = wave_number
	var wave_enemy_count := 0
	for spawner_data: SpawnerData in spawner_datas:
		if _wave_number >= spawner_data.starting_wave:
			var spawner := Spawner.new(spawner_data)
			spawner.level.set_value(wave_number)
			spawner.activate()
			wave_enemy_count += spawner.data.total_spawn_amount
			print("spawner (%d | %d) activated" % [spawner_data.starting_wave, wave_number])
		else:
			print("spawner (%d | %d) NOT activated" % [spawner_data.starting_wave, wave_number])
	_wave_enemies_left = wave_enemy_count
	print("enemies to kill in this wave: %d\n\n" % _wave_enemies_left)
	player.level.set_value(_wave_number)
	test_dummy.level.set_value(_wave_number)
	wave_started.emit(_wave_number)


func _start_next_wave() -> void:
	start_wave(_wave_number + 1)


func pause() -> void:
	_paused = true

func unpause() -> void:
	_paused = false

func is_playing() -> bool:
	return _playing

func is_paused() -> bool:
	return _paused

func go_to_main_menu() -> void:
	_playing = false

func quit() -> void:
	_save_data()
	get_tree().quit()


func _kill_all_enemies() -> void:
	for entity: Entity in entity_holder.get_children():
		if entity is Enemy:
			entity.queue_free()


func _load_weapon_datas() -> void:
	var path := "res://src/resources/"
	var files := ResourceLoader.list_directory(path)

	for file: String in files:
		weapon_datas.append(load(path + file))


func _on_enemy_died(enemy: Enemy) -> void:
	_wave_enemies_left -= 1
	_enemy_kill_count += 1
	_score += int(10 + ((_wave_number - 1) * 0.5))
	var weapon_drop: bool = randf() <= 0.02
	if weapon_drop:
		var rarity_set := RaritySet.new()
		var rarity := rarity_set.roll()
		var pos_x := enemy.global_position.x + randf_range(-1.0, 1.0)
		var pos_z := enemy.global_position.z + randf_range(-1.0, 1.0)
		var item_pos := Vector3(pos_x, 1.0, pos_z)
		var datas: Array[WeaponData]
		for data: WeaponData in weapon_datas:
			if data.rarity == rarity:
				datas.append(data)
		var weapon_data: WeaponData = datas.pick_random()
		weapon_data.level.set_value(enemy.level.value())
		Spawner.spawn_weapon(weapon_data, item_pos)
	# INFO temporary disabled
	# var coin_drop: bool = randf() <= 0.25
	# if coin_drop:
	# 	var amount := int((1.0 + ((enemy.level.value() - 1) * 0.1)) * randi_range(10, 100))
	# 	Spawner.spawn_coin(amount, enemy.position)
	var ammo_drop: bool = randf() <= 0.05
	if ammo_drop:
		var type: AmmoType = AmmoType.values().pick_random()
		var weight: AmmoWeight = AmmoWeight.values().pick_random()
		var level_mult: float = 1.0 + ((enemy.level.value() - 1) * 0.1)
		var type_mult: float = 4.0 if type == AmmoType.BULLET else 1.0
		var weight_mult: float = 3.0 - float(weight)
		var amount := int(randi_range(1, 10) * level_mult * type_mult * weight_mult)
		Spawner.spawn_ammo(amount, type, weight, enemy.position)



# temporary saving stuff
func _save_data() -> void:
	var config := ConfigFile.new()
	config.set_value("general", "high_score", _high_score)
	config.set_value("general", "best_wave", _best_wave)
	config.save_encrypted_pass(SAVE_LOAD_PATH, SAVE_LOAD_PASSWORD)

# temporary loading stuff
func _load_data() -> void:
	var config := ConfigFile.new()
	var err := config.load_encrypted_pass(SAVE_LOAD_PATH, SAVE_LOAD_PASSWORD)

	if err != OK:
		return

	_high_score = config.get_value("general", "high_score", 0)
	_best_wave = config.get_value("general", "best_wave", 0)


func _spawn_starter_weapon() -> void:
	var item_pos := Vector3(randf_range(-3.0, 3.0), 2.0, randf_range(-7.0, -3.0))
	var weapon_data: WeaponData
	if OS.has_feature("editor"):
		weapon_data = test_weapon_data
	else:
		weapon_data = starter_weapon_data
	weapon_data.level.set_value(1)
	Spawner.spawn_weapon(weapon_data, item_pos)
