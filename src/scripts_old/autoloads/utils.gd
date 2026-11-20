@tool
class_name Utils


#region Other

static func enum_to_string(enum_dict: Dictionary) -> PackedStringArray:
	return enum_dict.keys()

static func get_game_version() -> String:
	return ProjectSettings.get_setting("application/config/version")

static func _get_game_version_pretty() -> String:
	var version: String = ProjectSettings.get_setting("application/config/version")
	if version.ends_with("-prototype"):
		return "Prototype v%s" % version.trim_suffix("-prototype")
	elif version.ends_with("-alpha"):
		return "Alpha v%s" % version.trim_suffix("-alpha")
	elif version.ends_with("-beta"):
		return "Beta v%s" % version.trim_suffix("-beta")
	elif version[-1].is_valid_int():
		return "v%s" % version
	else:
		push_warning("Incorrect game version format in ProjectSettings/application/config/version")
		return "<error>"


static func class_name_of(object: Object) -> StringName:
	var script: Script = object.get_script()
	return script.get_global_name()

#endregion


#region Delay

# add editor functionality
func delay_s(s: float) -> void:
	var timer := Timer.new()
	timer.start(s)
	await timer.timeout
	timer.free()

# here too
static func delay_ms(ms: int) -> void:
	var timer := Timer.new()
	timer.start(ms / 1000.0)
	await timer.timeout
	timer.free()


static func delay_frame() -> void:
	await (Engine.get_main_loop() as SceneTree).process_frame

static func delay_physics_frame() -> void:
	await (Engine.get_main_loop() as SceneTree).physics_frame

static func delay_frames(count: int) -> void:
	for x: int in count:
		await delay_frame()

#endregion


#region Array Functions

## returns [code]true[/code] if [param array] is either an [class Array]
## or any [class Packed*Array], otherwise returns [code]false[/code]
static func is_array(array: Variant) -> bool:
	if array is Array \
	or array is PackedByteArray \
	or array is PackedInt32Array \
	or array is PackedInt64Array \
	or array is PackedFloat32Array \
	or array is PackedFloat64Array \
	or array is PackedStringArray \
	or array is PackedVector2Array \
	or array is PackedVector3Array \
	or array is PackedVector4Array \
	or array is PackedColorArray:
		return true
	return false


static func array_is_numeric(array: Variant) -> bool:
	if array is Array[int] \
	or array is Array[float] \
	or array is PackedByteArray \
	or array is PackedInt32Array \
	or array is PackedInt64Array \
	or array is PackedFloat32Array \
	or array is PackedFloat64Array:
		return true
	return false


static func array_sum(array: Array) -> float:
	if not array_is_numeric(array):
		push_warning("Not a numeric array (", array, ")")
		return 0.0
	var arr_sum := 0.0
	for f: float in array:
		arr_sum += f
	return arr_sum


static func array_fill_unique(arr: Array, method: Callable) -> void:
		for i: int in arr.size():
			arr[i] = method.call()
			i += 1

#func for_element_in(arr: Array, method: Callable) -> void:
#var i: int = 0
#var end: int = arr.size()
#while i < end:
	#method.call(arr[i])
	#i += 1

static func for_index_in(arr: Array, method: Callable) -> void:
	var i: int = 0
	var end: int = arr.size()
	while i < end:
		method.call(i)
		i += 1
	pass

#endregion


#region Physics

static func get_3d_physics_layers() -> Dictionary[StringName, int]:
	var layer_dict: Dictionary[StringName, int]
	for i: int in range(1, 33):
		var layer_path: StringName = "layer_names/3d_physics/layer_%d" % i
		var layer: StringName = ProjectSettings.get_setting(layer_path)
		if layer != null and layer != "":
			layer_dict[layer] = 1 << (i - 1)
	return layer_dict

static func get_3d_physics_layer(layer_name: StringName) -> int:
	for i: int in range(1, 33):
		var layer_path: StringName = "layer_names/3d_physics/layer_%d" % i
		var layer: StringName = ProjectSettings.get_setting(layer_path)
		if layer_name == layer:
			return 1 << (i - 1)
	push_error("3D Physics Layer '%s' does not exist, check for any typos" % layer_name)
	return 0

#endregion


#region Fun

static func print_project_code_info(scripts_folder_path: String = "res://src") -> void:
	var lines := get_code_lines_in_folder(scripts_folder_path)
	var chars := get_code_chars_in_folder(scripts_folder_path)
	print("-- Project Code Stats --")
	print("total lines of code: %d" % lines)
	print("total amount of chars: %d" % chars)

static func get_files_in_folder(path: String) -> Array[String]:
	var files: Array[String]
	var dir := DirAccess.open(path)

	dir.list_dir_begin()
	var filename := dir.get_next()

	while filename != "":
		if filename == "." or filename == "..":
			dir.get_next()
			continue

		if dir.current_is_dir():
			var sub_path := path.path_join(filename)
			files.append_array(get_files_in_folder(sub_path))
		else:
			files.append(path.path_join(filename))

		filename = dir.get_next()
	dir.list_dir_end()

	return files

static func get_code_lines_in_folder(folder_path: String) -> int:
	var files := get_files_in_folder(folder_path)

	files = files.filter(func(s: String) -> bool:
		return s.ends_with(".gd") or s.ends_with(".cs")
		)

	var count := 0
	for path: String in files:
		var file := FileAccess.open(path, FileAccess.READ)
		while not file.eof_reached():
			var line := file.get_line().strip_edges()
			if line.begins_with("#") or line.is_empty():
				continue
			count += 1
		file.close()

	return count

static func get_code_chars_in_folder(folder_path: String) -> int:
	var files := get_files_in_folder(folder_path)

	files = files.filter(func(s: String) -> bool:
		return s.ends_with(".gd")
		)

	var count := 0
	for path: String in files:
		var file := FileAccess.open(path, FileAccess.READ)
		while not file.eof_reached():
			var line := file.get_line().strip_edges()
			if line.begins_with("#") or line.is_empty():
				continue
			for c: String in line:
				if " \n\t".contains(c):
					continue
				count += 1
		file.close()

	return count

#endregion
