extends MenuButton
class_name InventorySlot

var __tooltip_scene: PackedScene = preload("res://src/scenes/weapon_tooltip.tscn")
static var __tooltip: WeaponTooltip = null

const __EQUIP_ID := 0
const __UNEQUIP_ID := 4
const __DELETE_ID := 1

var __inventory: PlayerInventory
var __index: int
var __is_equip_slot: bool = false

#@onready var label: Label = $Label
@export var label: Label

func init_slot(inventory: PlayerInventory, index: int) -> void:
	__inventory = inventory
	__index = index
	label.text = ""
	var popup := get_popup()
	popup.add_item("Equip", __EQUIP_ID)
	popup.add_item("Delete", __DELETE_ID)

func init_equip_slot(inventory: PlayerInventory) -> void:
	__inventory = inventory
	__is_equip_slot = true
	__index = -1
	label.text = ""
	var popup := get_popup()
	popup.add_item("Unequip", __UNEQUIP_ID)
	popup.add_item("Delete", __DELETE_ID)


func _ready() -> void:
	if __tooltip == null:
		__init_tooltip()
	get_popup().id_pressed.connect(func(id: int) -> void:
		match id:
			__EQUIP_ID:
				var data := __inventory.get_equipped_weapon_data()
				__inventory.equip(__inventory.at(__index))
				__inventory.delete(__index)
				__inventory.insert(__index, data)
			__DELETE_ID:
				__inventory.delete(__index)
			__UNEQUIP_ID:
				__inventory.unequip()
		)
	mouse_entered.connect(func() -> void:
		var data: WeaponData
		if not __is_equip_slot:
			data = __inventory.at(__index)
		else:
			data = __inventory.get_equipped_weapon_data()
		if data == null:
			return
		__tooltip.target = self
		__tooltip.display(data)
		#print("displayed")
		)
	mouse_exited.connect(__tooltip.hide)


func update_data(data: WeaponData) -> void:
	if data == null:
		disabled = true
		label.text = ""
		return
	disabled = false
	label.add_theme_color_override("font_color", Game.RARITY_COLORS[data.rarity])
	label.text = data.weapon_name

func remove_data() -> void:
	disabled = true
	label.text = ""


func __init_tooltip() -> void:
	__tooltip = __tooltip_scene.instantiate() as WeaponTooltip
	__tooltip.offset = Vector2(116, -32)
	Game.inst.ui_canvas_root.add_child.call_deferred(__tooltip)
