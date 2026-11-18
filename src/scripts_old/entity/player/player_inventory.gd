extends RefCounted
class_name PlayerInventory

var __player: Player

const SIZE := 256

signal weapon_equipped(weapon: WeaponData)
signal weapon_unequipped(weapon: WeaponData)
#signal weapon_added(weapon: WeaponData)
#signal inventory_changed
signal index_changed(index: int, data: WeaponData)
signal ammo_amount_changed


# [int: integer key containing AmmoType and AmmoWeight data, int: amount of ammo]
var _ammos: Dictionary[int, int]

var _coins: int

var __weapons: Array[WeaponData]
#var __slots: Array[InventorySlot]

var __equipped_weapon_data: WeaponData = null

#var __equipped_index: int
#var __equip_slot: InventorySlot

#var __ui: Node


func _init(player: Player) -> void:
	__player = player
	__weapons.resize(SIZE)
	#__slots.resize(SIZE)


func at(index: int) -> WeaponData:
	if not is_valid_index(index):
		return null
	return __weapons[index]


func add(weapon: WeaponData) -> void:
	var index := __get_empty_index()
	if not is_valid_index(index):
		return
	__weapons[index] = weapon
	index_changed.emit(index, weapon)
	#weapon_added.emit(weapon)

func insert(index: int, weapon: WeaponData) -> void:
	if not is_valid_index(index):
		return
	if __weapons[index] != null:
		push_warning("The index '%d' is already used" % index)
	__weapons[index] = weapon
	index_changed.emit(index, weapon)

func remove_at(index: int) -> void:
	__weapons[index] = null
	index_changed.emit(index, null)

func clear() -> void:
	for index: int in __weapons.size():
		remove_at(index)
	weapon_unequipped.emit(__equipped_weapon_data)
	__equipped_weapon_data = null


func equip(weapon: WeaponData) -> void:
	__equipped_weapon_data = weapon
	weapon_equipped.emit(__equipped_weapon_data)

func unequip() -> void:
	var data := __equipped_weapon_data
	add(data)
	__equipped_weapon_data = null
	print(__equipped_weapon_data)
	weapon_unequipped.emit(data)


func get_equipped_weapon_data() -> WeaponData:
	return __equipped_weapon_data


func is_valid_index(index: int) -> bool:
	if index >= __weapons.size() or index < 0:
		push_warning("Index '%d' is out of bounds" % index)
		return false
	return true


func is_full() -> bool:
	return __get_empty_index() == -1


func __get_empty_index() -> int:
	for index: int in SIZE:
		if __weapons[index] == null:
			return index
	return -1


func add_ammo(amount: int, type: Game.AmmoType, weight: Game.AmmoWeight) -> void:
	# convert the Enum Values to integeres and create a key out fo them
	var key: int = type + weight * 10
	_ammos[key] = _ammos.get(key, 0) + amount
	ammo_amount_changed.emit()

func set_ammo(amount: int, type: Game.AmmoType, weight: Game.AmmoWeight) -> void:
	# convert the Enum Values to integeres and create a key out fo them
	var key: int = type + weight * 10
	_ammos[key] = amount
	ammo_amount_changed.emit()

func remove_ammo(amount: int, type: Game.AmmoType, weight: Game.AmmoWeight) -> void:
	# convert the Enum Values to integeres and create a key out fo them
	var key: int = type + weight * 10
	_ammos[key] = _ammos.get(key, 0) - amount
	ammo_amount_changed.emit()

func get_ammo(type: Game.AmmoType, weight: Game.AmmoWeight) -> int:
	# convert the Enum Values to integeres and create a key out fo them
	var key: int = type + weight * 10
	return _ammos.get(key, 0)


func set_coins(amount: int) -> void:
	_coins = amount

func add_coins(amount: int) -> void:
	_coins += amount

func get_coind() -> int:
	return _coins
