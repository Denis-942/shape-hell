@tool
extends Resource
class_name RaritySet


@warning_ignore("unused_private_class_variable")
@export_tool_button("Validate") var ___validate_tool_button := func() -> void:
	validate()
	notify_property_list_changed()

@warning_ignore("unused_private_class_variable")
@export_tool_button("Recalculate") var ___recalculate_tool_button := func() -> void:
	recalculate()
	notify_property_list_changed()

@warning_ignore("unused_private_class_variable")
@export_tool_button("Reset") var ___reset_tool_button := func() -> void:
	reset_chances()
	notify_property_list_changed()



const DEFAULT_RARITY_DICT: Dictionary[Game.Rarity, float] = {
	Game.Rarity.COMMON: 0.35,
	Game.Rarity.UNCOMMON: 0.28,
	Game.Rarity.RARE: 0.20,
	Game.Rarity.EPIC: 0.12,
	Game.Rarity.LEGENDARY: 0.05,
}

@export var __rarity_dict: Dictionary[Game.Rarity, float] = DEFAULT_RARITY_DICT.duplicate()


#var __luck_multiplier: float = 1.0
#
#func _init() -> void:
	#__rarity_dict = DEFAULT_RARITY_DICT.duplicate()

static func create(rarity_dict: Dictionary[Game.Rarity, float]) -> RaritySet:
	var rarity_set := RaritySet.new()
	rarity_set.set_rarity_dict(rarity_dict)
	if not rarity_set.validate():
		return null
	return rarity_set


func roll() -> Game.Rarity:
	if not validate():
		return 0 as Game.Rarity
	var x := randf()
	#print("rolled %.2f" % x)
	var weight := 0.0
	for rarity: Game.Rarity in __rarity_dict.keys():
		if x <= __rarity_dict[rarity] + weight:
			#print_rich("\nrolled [color=%s]%s" % [Game.RARITY_COLORS[rarity].to_html(), Utils.enum_to_string(Game.Rarity)[rarity]])
			return rarity
		else:
			weight += __rarity_dict[rarity]
	
	push_error("Could not roll a rarity")
	return 0 as Game.Rarity

func get_rarity_dict() -> Dictionary[Game.Rarity, float]:
	return __rarity_dict

func set_rarity_dict(rarity_dict: Dictionary[Game.Rarity, float]) -> void:
	__rarity_dict = rarity_dict

func get_rarities() -> Array[Game.Rarity]:
	return __rarity_dict.keys()

func set_rarities(rarities: Array[Game.Rarity]) -> void:
	var new_rarities: Dictionary[Game.Rarity, float]
	for rarity: Game.Rarity in rarities:
		new_rarities[rarity] = __rarity_dict[rarity]
	__rarity_dict = new_rarities


func get_chance(rarity: Game.Rarity) -> float:
	return __rarity_dict[rarity]

func get_chances() -> Array[float]:
	return __rarity_dict.values()

func set_chance(rarity: Game.Rarity, chance: float) -> void:
	if not __rarity_dict.has(rarity):
		push_warning("RaritySet '%s' does not have Rarity '%s'" % [
			self, Utils.enum_to_string(Game.Rarity)[rarity]])
	__rarity_dict[rarity] = chance

func set_chances(dict: Dictionary[Game.Rarity, float]) -> void:
	for rarity: Game.Rarity in dict.keys():
		__rarity_dict[rarity] = dict[rarity]

func reset_chance(rarity: Game.Rarity) -> void:
	__rarity_dict[rarity] = DEFAULT_RARITY_DICT[rarity]

func reset_chances() -> void:
	for rarity: Game.Rarity in __rarity_dict.keys():
		__rarity_dict[rarity] = DEFAULT_RARITY_DICT[rarity]

func add_rarity(rarity: Game.Rarity, chance: float) -> void:
	if __rarity_dict.has(rarity):
		push_warning("RaritySet '%s' already has Rarity '%s'" % [
			self, Utils.enum_to_string(Game.Rarity)[rarity]])
	__rarity_dict[rarity] = chance

func remove_rarity(rarity: Game.Rarity) -> void:
	if not __rarity_dict.has(rarity):
		push_warning("RaritySet '%s' does not have Rarity '%s'" % [
			self, Utils.enum_to_string(Game.Rarity)[rarity]])
	__rarity_dict.erase(rarity)

func has_rarity(rarity: Game.Rarity) -> bool:
	return __rarity_dict.has(rarity)


func validate() -> bool:
	if are_chances_valid():
		return true
	else:
		push_error("The chances do not add up to 1.0 (100%%) (they add up to %.2f)" % \
			Utils.array_sum(get_chances()))
		return false

# Utils.get_array_sum()
# Utils.array.sum()
# Utils.Array.sum()

func are_chances_valid() -> bool:
	if is_equal_approx(Utils.array_sum(get_chances()), 1.0):
		return true
	else:
		return false


func recalculate() -> void:
	if are_chances_valid():
		return
	var current_weight: float = Utils.array_sum(get_chances())
	var multiplier: float = 1.0 / current_weight
	print("multiplier: ", multiplier)
	for rarity: Game.Rarity in __rarity_dict:
		set_chance(rarity, __rarity_dict[rarity] * multiplier)
	
	if are_chances_valid():
		print("recalculation successful")
	else:
		print("recalculation NOT successful")
	
	#for rarity: Game.Rarity in __rarity_dict:
		#print(Utils.enum_to_string(Game.Rarity)[rarity], ": ", __rarity_dict[rarity])
