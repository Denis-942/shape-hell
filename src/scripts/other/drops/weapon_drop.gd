extends ItemDrop
class_name WeaponDrop


var data: WeaponData


func _ready() -> void:
	# INFO delay the execution by 1 process frame so all properties are ready
	await Utils.delay_frame()
	
	var mat := StandardMaterial3D.new()
	
	# INFO set the material color to the corresponding rarity color
	mat.albedo_color = Game.RARITY_COLORS[data.rarity]
	_mesh.set_surface_override_material(0, mat)
	
	# INFO set the despawn timer depending on the rarity, higher rarity = longer time
	_despawn_timer = 20.0 + ((data.rarity as int) * 10.0)


func collect() -> WeaponData:
	queue_free()
	return data
