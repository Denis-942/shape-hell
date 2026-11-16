extends Node


@export_subgroup("Main Menu", "main_menu_")
@export var main_menu: Control
@export var main_menu_start_button: Button
@export var main_menu_quit_button: Button
@export var main_menu_high_score_label: Label
@export var main_menu_best_wave_label: Label
@export var main_menu_playtime_label: Label
@export var main_menu_camera: Camera3D

@export_subgroup("Pause Menu", "pause_menu_")
@export var pause_menu: Control
@export var pause_menu_resume_button: Button
@export var pause_menu_main_menu_button: Button

@export_subgroup("Death Menu", "death_menu_")
@export var death_menu: Control
@export var death_menu_restart_button: Button
@export var death_menu_main_menu_button: Button
@export var death_menu_enemy_kill_count_label: Label

@export_subgroup("Inventory Menu", "inventory_menu_")
@export var inventory_menu: Control
@export var inventory_menu_equip_slot: InventorySlot
@export var inventory_menu_slots: Control

@export_subgroup("Gameplay Overlay", "gameplay_overlay_")
@export var gameplay_overlay: Control
@export var gameplay_overlay_score_label: Label
@export var gameplay_overlay_high_score_label: Label
@export var gameplay_overlay_wave_label: Label
@export var gameplay_overlay_best_wave_label: Label
@export_subgroup("Gameplay Overlay/Player", "gameplay_overlay_player_")
@export var gameplay_overlay_player_health_progress_bar: ProgressBar
@export var gameplay_overlay_player_health_label: Label
@export var gameplay_overlay_player_health_percentage_label: Label
@export var gameplay_overlay_player_ammo_label: Label
@export var gameplay_overlay_player_bullet_ammo_reserve_label: Label
@export var gameplay_overlay_player_shell_ammo_reserve_label: Label



var _inventory_slot_scene := preload("res://src/scenes/inventory_slot.tscn")


var _menus: Array[Control]
var _active_overlays: Array[Control]

var _inventory_slots: Array[InventorySlot]


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	_init_ui_signals()
	_init_game_signals()
	_menus.append(main_menu)
	_menus.append(pause_menu)
	_menus.append(death_menu)
	_menus.append(inventory_menu)

	await Utils.delay_frame()
	_init_inventory_slots()
	var inv := Game.inst.player.get_inventory()
	inv.index_changed.connect(_on_inventory_index_changed)
	inv.weapon_equipped.connect(_on_inventory_weapon_equipped)
	inv.weapon_unequipped.connect(_on_inventory_weapon_unequipped)

	hide_overlay(gameplay_overlay)
	show_menu(main_menu)


func _init_ui_signals() -> void:
	# main menu
	main_menu_start_button.pressed.connect(Game.inst.start)
	main_menu_quit_button.pressed.connect(Game.inst.quit)
	# pause menu
	pause_menu_resume_button.pressed.connect(Game.inst.unpause)
	pause_menu_main_menu_button.pressed.connect(Game.inst.go_to_main_menu)
	# death menu
	death_menu_restart_button.pressed.connect(Game.inst.start)
	death_menu_main_menu_button.pressed.connect(Game.inst.go_to_main_menu)

	gameplay_overlay_player_ammo_label.text = "0 / 0"
	gameplay_overlay_player_bullet_ammo_reserve_label.text = "Bullets  0 L / 0 M / 0 H"
	gameplay_overlay_player_shell_ammo_reserve_label.text = "Shells   0 L / 0 M / 0 H"


func _init_game_signals() -> void:
	Game.inst.player_died.connect(show_menu.bind(death_menu))
	Game.inst.player.health_changed.connect(_on_player_health_changed)
	Game.inst.score_changed.connect(_on_game_score_changed)
	Game.inst.high_score_changed.connect(_on_game_high_score_changed)
	Game.inst.best_wave_changed.connect(_on_game_best_wave_changed)
	Game.inst.playtime_changed.connect(func(new_value_s: float) -> void:
		main_menu_playtime_label.text = "Playtime: %ds" % int(new_value_s)
		)
	Game.inst.enemy_kill_count_changed.connect(func(value: int) -> void:
		death_menu_enemy_kill_count_label.text = "Enemies killed in this life: %d" % value
		)
	Game.inst.paused.connect(show_menu.bind(pause_menu))
	Game.inst.unpaused.connect(hide_all_menus)
	Game.inst.inventory_opened.connect(show_menu.bind(inventory_menu))
	Game.inst.inventory_closed.connect(hide_all_menus)
	Game.inst.started.connect(func() -> void:
		hide_all_menus()
		show_overlay(gameplay_overlay)
		)
	Game.inst.stopped.connect(func() -> void:
		hide_overlay(gameplay_overlay)
		hide_all_menus()
		show_menu(main_menu)
		print("changed to main menu")
		)
	Game.inst.wave_started.connect(func(wave_number: int) -> void:
		gameplay_overlay_wave_label.text = "Wave %d" % wave_number
		)
	var inv := Game.inst.player.get_inventory()
	inv.weapon_equipped.connect(func(data: WeaponData) -> void:
		gameplay_overlay_player_ammo_label.text = "%d / %d" % [
			data.ammo, data.max_ammo]
		#gameplay_overlay_player_reserved_ammo_label.text = "Reserve: %d / %d" % [
		#	data.reserved_ammo, data.max_reserved_ammo]
		#inv.ammo_amount_changed.connect(func(amount: int) -> void:
		#	gameplay_overlay_player_ammo_label.text = "Ammo: %d / %d" % [
		#		amount, data.max_ammo]
		#	)
		Game.inst.player.current_weapon.ammo_amount_changed.connect(func(amount: int) -> void:
			gameplay_overlay_player_ammo_label.text = "%d / %d" % [
				amount, data.max_ammo]
			)
		)
	inv.weapon_unequipped.connect(func(_data: WeaponData) -> void:
		gameplay_overlay_player_ammo_label.text = "0 / 0"
		)
	inv.ammo_amount_changed.connect(func() -> void:
		var type_bullet := Game.AmmoType.BULLET
		var type_shell := Game.AmmoType.SHELL
		var weight_l := Game.AmmoWeight.LIGHT
		var weight_m := Game.AmmoWeight.MEDIUM
		var weight_h := Game.AmmoWeight.HEAVY
		var bullets_l: int = inv.get_ammo(type_bullet, weight_l)
		var bullets_m: int = inv.get_ammo(type_bullet, weight_m)
		var bullets_h: int = inv.get_ammo(type_bullet, weight_h)
		var shells_l: int = inv.get_ammo(type_shell, weight_l)
		var shells_m: int = inv.get_ammo(type_shell, weight_m)
		var shells_h: int = inv.get_ammo(type_shell, weight_h)
		gameplay_overlay_player_bullet_ammo_reserve_label.text = "Bullets  %d L / %d M / %d H" % [
			bullets_l, bullets_m, bullets_h]
		gameplay_overlay_player_shell_ammo_reserve_label.text = "Shells   %d L / %d M / %d H" % [
			shells_l, shells_m, shells_h]
		)

func hide_all_menus() -> void:
	for menu: Control in _menus:
		hide_menu(menu)


func show_menu(menu: Control) -> void:
	#if not _menus.has(menu):
	#	return
	hide_all_menus()
	menu.show()
	# reorder the menu to the back
	_menus.erase(menu)
	_menus.append(menu)
	#_apply_menus_z_index()

func show_last_menu() -> void:
	var last_menu := _menus[_menus.size() - 2]
	show_menu(last_menu)

func hide_menu(menu: Control) -> void:
	menu.hide()

func toggle_menu(menu: Control) -> void:
	if not menu.visible:
		show_menu(menu)
	else:
		hide_menu(menu)

#func _apply_menus_z_index() -> void:
#	for i: int in _active_menus.size():
#		_active_menus[i].z_index = i


func show_overlay(overlay: Control) -> void:
	overlay.show()
	if not _active_overlays.has(overlay):
		_active_overlays.append(overlay)

func hide_overlay(overlay: Control) -> void:
	overlay.hide()
	if _active_overlays.has(overlay):
		_active_overlays.erase(overlay)


func _on_player_health_changed(old_value: float, new_value: float) -> void:
	var player := Game.inst.player
	var tween := create_tween() \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	#tween.set_ignore_time_scale(true)
	#tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var v1 := remap(old_value, 0.0, player.get_max_health(), 0.0, 1.0)
	var v2 := remap(new_value, 0.0, player.get_max_health(), 0.0, 1.0)
	tween.tween_method(_update_player_health_ui, v1, v2, 0.75)

func _update_player_health_ui(value: float) -> void:
	var bar := gameplay_overlay_player_health_progress_bar
	var stylebox := bar.get_theme_stylebox("fill").duplicate() as StyleBoxFlat
	#var v: float = 0.55 + (0.15 * value) + (0.25 * (min(value * 3.0, 1.0)))
	var v: float = 0.85 #- (0.4 * (1.0 - (value ** 1.25)))
	var c := Color.from_hsv(remap(value, 0.0, 1.0, 0.0, 0.35), 1.0, v)
	stylebox.bg_color = c
	bar.add_theme_stylebox_override("fill", stylebox)
	bar.value = remap(value, 0.0, 1.0, bar.min_value, bar.max_value)
	var health: float = Game.inst.player.get_health()
	var max_health: float = Game.inst.player.get_max_health()
	gameplay_overlay_player_health_label.text = "%.1f / %.1f" % [health, max_health]
	gameplay_overlay_player_health_percentage_label.text = "%d%%" % roundi((health / max_health) * 100)

func _init_inventory_slots() -> void:
	for node: Node in inventory_menu_slots.get_children():
		node.queue_free()
	var inv := Game.inst.player.get_inventory()
	_inventory_slots.resize(inv.SIZE)
	for index: int in inv.SIZE:
		var slot := _inventory_slot_scene.instantiate() as InventorySlot
		inventory_menu_slots.add_child(slot)
		slot.init_slot(inv, index)
		_inventory_slots[index] = slot
	inventory_menu_equip_slot.init_equip_slot(inv)

func _on_inventory_index_changed(index: int, data: WeaponData) -> void:
	_inventory_slots[index].update_data(data)

func _on_inventory_weapon_equipped(weapon: WeaponData) -> void:
	inventory_menu_equip_slot.update_data(weapon)

func _on_inventory_weapon_unequipped(_weapon: WeaponData) -> void:
	inventory_menu_equip_slot.remove_data()


func _on_game_score_changed(new_score: int) -> void:
	gameplay_overlay_score_label.text = "Score: %d" % new_score

func _on_game_high_score_changed(new_high_score: int) -> void:
	if new_high_score > 0:
		main_menu_high_score_label.text = "High score: %d" % new_high_score
		gameplay_overlay_high_score_label.text = "Best: %d" % new_high_score
	else:
		main_menu_high_score_label.text = ""
		gameplay_overlay_high_score_label.text = ""

func _on_game_best_wave_changed(new_best_wave: int) -> void:
	if new_best_wave > 0:
		main_menu_best_wave_label.text = "Best wave: %d" % new_best_wave
		gameplay_overlay_best_wave_label.text = "Best: %d" % new_best_wave
	else:
		main_menu_best_wave_label.text = ""
		gameplay_overlay_best_wave_label.text = ""
