@tool
extends RichTextLabel
class_name GameVersionLabel

enum VersionType {
	BASIC,
	PRETTY,
}
@export var version_type: VersionType = VersionType.BASIC:
	get:
		return version_type
	set(value):
		version_type = value
		_update_text()
@export_multiline var prefix: String = "":
	get:
		return prefix
	set(value):
		prefix = value
		_update_text()
@export_multiline var suffix: String = "":
	get:
		return suffix
	set(value):
		suffix = value
		_update_text()

func _enter_tree() -> void:
	_update_text()


func _update_text() -> void:
	match version_type:
		VersionType.BASIC:
			text = "%s%s%s" % [prefix, _get_game_version(), suffix]
		VersionType.PRETTY:
			text = "%s%s%s" % [prefix, _get_game_version_pretty(), suffix]



func _get_game_version() -> String:
	return ProjectSettings.get_setting("application/config/version")

func _get_game_version_pretty() -> String:
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
