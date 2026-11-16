extends Tooltip
class_name WeaponTooltip


@export var weapon_name_label: Label
@export var weapon_level_label: RichTextLabel
@export var rarity_label: RichTextLabel
@export var damage_label: RichTextLabel
@export var burst_label: RichTextLabel
@export var rpm_label: RichTextLabel
@export var max_ammo_label: RichTextLabel
@export var ammo_type_label: RichTextLabel
@export var ammo_weight_label: RichTextLabel
@export var reload_time_label: RichTextLabel
@export var pierce_label: RichTextLabel
@export var range_label: RichTextLabel
@export var velocity_label: RichTextLabel
@export var spread_label: RichTextLabel


func display(data: WeaponData) -> void:
	show()
	weapon_name_label.text = data.weapon_name
	weapon_level_label.text = "[color=cyan]Level %d[/color]" % data.level.value()
	rarity_label.text = "[color=%s]%s" % [
		Game.RARITY_COLORS[data.rarity].to_html(),
		Utils.enum_to_string(Game.Rarity)[data.rarity]]
	var padding := 34
	damage_label.text = "[color=#eee]Damage[/color]".rpad(padding) + str(data.damage.scaled)
	burst_label.visible = data.is_burst_fire()
	burst_label.text = "[color=#eee]Burst[/color]".rpad(padding) + str(data.get_burst_count())
	rpm_label.text = "[color=#eee]Firerate[/color]".rpad(padding) + "%d [color=gray]rpm" % data.rpm

	max_ammo_label.text = "[color=#eee]Max Ammo[/color]".rpad(padding) + str(data.max_ammo)
	var ammo_type_enum_str := Utils.enum_to_string(Game.AmmoType)[data.ammo_type].to_pascal_case()
	ammo_type_label.text = "[color=#eee]Ammo Type[/color]".rpad(padding) + ammo_type_enum_str
	var ammo_weight_enum_str := Utils.enum_to_string(Game.AmmoWeight)[data.ammo_weight].to_pascal_case()
	ammo_weight_label.text = "[color=#eee]Ammo Weight[/color]".rpad(padding) + ammo_weight_enum_str
	reload_time_label.text = "[color=#eee]Reload Time[/color]".rpad(padding) + "%.2f[color=gray]s" % data.reload_time

	pierce_label.text = "[color=#eee]Pierce[/color]".rpad(padding) + str(data.pierce)
	range_label.text = "[color=#eee]Range[/color]".rpad(padding) + "%.1f [color=gray]m" % data.projectile_range
	velocity_label.text = "[color=#eee]Velocity[/color]".rpad(padding) + "%.1f [color=gray]m/s" % data.projectile_velocity
	spread_label.text = "[color=#eee]Spread[/color]".rpad(padding) + "%.1f[color=gray]\u00B0" % data.spread_angle
