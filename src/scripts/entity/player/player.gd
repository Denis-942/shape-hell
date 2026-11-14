extends Entity
class_name Player

@export var collect_area: Area3D
@export var camera: Camera3D
@export var orientation: Node3D
@export var hand: Node3D
const camera_zoom_sensitivity: float = 2.0
const MAX_CAMERA_ZOOM: float = 100.0 # default 10-12
const MIN_CAMERA_ZOOM: float = 4.0


var __movement: PlayerMovement
var __inventory: PlayerInventory

@export var current_weapon: RangedWeapon
#@export var weapon_data: WeaponData


var __passive_health_regen_min_heal_percentage: float = 0.02
var __passive_health_regen_max_heal_percentage: float = 0.10
var __passive_health_regen_min_cooldown: float = 1.0
var __passive_health_regen_max_cooldown: float = 5.0
var __passive_health_regen_timer: float
var __passive_health_regen_count: int = 0


func _ready() -> void:
	__movement = PlayerMovement.new(self)
	__inventory = PlayerInventory.new(self)
	#UI.main_menu_hidden.connect(func() -> void:
		#camera.current = Game.is_playing()
		#)
	Game.inst.started.connect(func() -> void:
		camera.current = true
		)
	Game.inst.stopped.connect(func() -> void:
		camera.current = false
		)
	Game.inst.started.connect(func() -> void:
		_health_state = HealthState.ALIVE
		)
	#level.changed.connect(func(new_value: int) -> void:
	#	heal(_max_health.scaled(new_value))
	#	)
	#Game.player_died.connect(func() -> void:
		#_health_state = HealthState.DEAD
		#)
	collect_area.body_entered.connect(__on_collect_area_body_entered)
	#var item := Game.test_weapon_data.create_item_instance()
	#Game.nodes.game_map.add_child.call_deferred(item)
	#_health = _max_health.scaled(level.value())
	#position = Vector3(0.6, 0, 0)
	#set_physics_process(false)
	__inventory.weapon_equipped.connect(__on_inventory_weapon_equipped)
	__inventory.weapon_unequipped.connect(__on_inventory_weapon_unequipped)


func _process(delta: float) -> void:
	__handle_primary()
	__handle_passive_health_regen(delta)
	#__handle_equip_unequip()
	#if Input.is_action_just_pressed("0"):
		#heal(10)
	#elif Input.is_action_just_pressed("9"):
		#take_damage(10)


func _physics_process(delta: float) -> void:
	_handle_gravity(delta)
	__movement.owner_physics_process(delta)
	__handle_zoom_in_out()


func __on_collect_area_body_entered(body: Node3D) -> void:
	if body is WeaponDrop:
		if __inventory.is_full():
			return
		var weapon_item := body as WeaponDrop
		__inventory.add(weapon_item.collect())
	elif body is AmmoDrop:
		var ammo := body as AmmoDrop
		__inventory.add_ammo(ammo.collect(), ammo.type, ammo.weight)
	elif body is CoinDrop:
		var coin := body as CoinDrop
		__inventory.add_coins(coin.collect())
	else:
		print("not a weapon item")


func _take_damage(amount: float) -> void:
	super._take_damage(amount)
	__passive_health_regen_count = 0
	__passive_health_regen_timer = __passive_health_regen_max_cooldown


func _die() -> void:
	#super._die()
	if _health_state == HealthState.DEAD:
		return
	_health_state = HealthState.DEAD
	Game.inst.player_died.emit()
	print("the player has died")


func __on_inventory_weapon_equipped(weapon: WeaponData) -> void:
	for node: Node in hand.get_children():
		node.queue_free()
	current_weapon = weapon.equip()
	hand.add_child(current_weapon)
	current_weapon.position = Vector3.ZERO
	current_weapon.rotation = Vector3.ZERO


func __on_inventory_weapon_unequipped(_weapon: WeaponData) -> void:
	#print("unequip", weapon)
	for node: Node in hand.get_children():
		node.queue_free()
	current_weapon = null


func __handle_primary() -> void:
	if current_weapon == null:
		return
	#if current_weapon is RangedWeapon and weapon_data.is_equipped():
	var gun := current_weapon as RangedWeapon
	if Input.is_action_just_pressed("use_primary"):
		gun.shoot_start()
	elif Input.is_action_just_released("use_primary"):
		gun.shoot_end()
	elif Input.is_action_just_pressed("reload"):
		@warning_ignore("missing_await")
		gun.reload()


#func __handle_equip_unequip() -> void:
	#if Input.is_action_just_pressed("equip"):
		#if weapon_data == null:
			#return
		#if not weapon_data.is_equipped():
			#__equip_weapon()
		#else:
			#__unequip_weapon()


#func __shoot_start() -> void:
	#__shoot_time = 0.0
#
#
#func __shoot_end() -> void:
	#pass

func __handle_passive_health_regen(delta: float) -> void:
	if _health < get_max_health():
		__passive_health_regen_timer -= delta
		if __passive_health_regen_timer <= 0.0:
			var count := __passive_health_regen_count
			var max_cooldown := __passive_health_regen_max_cooldown
			var min_cooldown := __passive_health_regen_min_cooldown
			var min_regen_perc := __passive_health_regen_min_heal_percentage
			var max_regen_perc := __passive_health_regen_max_heal_percentage
			var heal_perc := minf(min_regen_perc + (0.01 * count), max_regen_perc)
			heal(heal_perc * get_max_health())
			__passive_health_regen_timer = maxf(max_cooldown - (1.0 * count), min_cooldown)
			__passive_health_regen_count += 1
			
			#__passive_health_regen_timer = __passive_health_regen_cooldown - ()
	pass


func __handle_zoom_in_out() -> void:
	if Input.is_action_just_pressed("zoom_in"):
		camera.position.z = max(camera.position.z - camera_zoom_sensitivity, MIN_CAMERA_ZOOM)
	elif Input.is_action_just_pressed("zoom_out"):
		camera.position.z = min(camera.position.z + camera_zoom_sensitivity, MAX_CAMERA_ZOOM)


func get_inventory() -> PlayerInventory:
	return __inventory
