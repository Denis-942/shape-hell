extends Tooltip
class_name WeaponTooltip


@export var weapon_name_label: Label
@export var weapon_level_label: RichTextLabel
@export var rarity_label: RichTextLabel
@export var damage_label: RichTextLabel
@export var burst_label: RichTextLabel
@export var rpm_label: RichTextLabel
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
	var padding := 30
	damage_label.text = "[color=#eee]Damage[/color]".rpad(padding) + str(data.damage.scaled)
	burst_label.visible = data.is_burst_fire()
	burst_label.text = "[color=#eee]Burst[/color]".rpad(padding) + str(data.get_burst_count())
	rpm_label.text = "[color=#eee]Firerate[/color]".rpad(padding) + "%d [color=gray]rpm" % data.rpm
	pierce_label.text = "[color=#eee]Pierce[/color]".rpad(padding) + str(data.pierce)
	range_label.text = "[color=#eee]Range[/color]".rpad(padding) + "%.1f [color=gray]m" % data.projectile_range
	velocity_label.text = "[color=#eee]Velocity[/color]".rpad(padding) + "%.1f [color=gray]m/s" % data.projectile_velocity
	spread_label.text = "[color=#eee]Spread[/color]".rpad(padding) + "%.1f[color=gray]\u00B0" % data.spread_angle
