extends ItemDrop
class_name AmmoDrop


var amount: int
var type: Game.AmmoType
var weight: Game.AmmoWeight


func _ready() -> void:
	# INFO delay the execution by 1 process frame so all properties are ready
	await Utils.delay_frame()
	
	var mesh := _mesh.mesh as BoxMesh
	var mat := StandardMaterial3D.new()
	var mat_color: Color
	
	# INFO change the mesh's size and material color based on the ammo type
	match type:
		Game.AmmoType.BULLET:
			mesh.size = Vector3(0.4, 0.3, 0.4)
			mat_color = Color.YELLOW
		Game.AmmoType.SHELL:
			mesh.size = Vector3(0.35, 0.5, 0.25)
			mat_color = Color.RED
	
	# INFO change the size of the mesh depending on the weight
	var mesh_size: Vector3 = mesh.size * Vector3(1.0 + weight * 0.25, 1.0 + weight * 0.1, 1.0 + weight * 0.25)
	mesh.size = mesh_size
	
	# INFO decrease the contrast of the material color depending on the weight
	mat_color = mat_color.lightened(0.5 - weight * 0.1)
	mat.albedo_color = mat_color
	
	# INFO set the final material for the mesh instance
	_mesh.set_surface_override_material(0, mat)


func collect() -> int:
	queue_free()
	return amount
