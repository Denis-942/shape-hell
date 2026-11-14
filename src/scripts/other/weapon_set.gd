extends RefCounted
class_name WeaponSet
## @experimental


var __weapons: Array[WeaponData]


static func create(weapon_datas: Array[WeaponData]) -> WeaponSet:
	var weapon_set := WeaponSet.new()
	weapon_set.set_weapons(weapon_datas)
	return weapon_set


func add(weapon_data: WeaponData) -> void:
	__weapons.append(weapon_data)

func remove(weapon_data: WeaponData) -> void:
	__weapons.erase(weapon_data)


func get_weapons() -> Array[WeaponData]:
	return __weapons

func set_weapons(weapon_datas: Array[WeaponData]) -> void:
	__weapons = weapon_datas
