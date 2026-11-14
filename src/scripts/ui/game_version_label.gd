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
		__update_text()
@export_multiline var prefix: String = "":
	get:
		return prefix
	set(value):
		prefix = value
		__update_text()
@export_multiline var suffix: String = "":
	get:
		return suffix
	set(value):
		suffix = value
		__update_text()

func _enter_tree() -> void:
	__update_text()


func __update_text() -> void:
	match version_type:
		VersionType.BASIC:
			text = "%s%s%s" % [prefix, __get_game_version(), suffix]
		VersionType.PRETTY:
			text = "%s%s%s" % [prefix, __get_game_version_pretty(), suffix]



func __get_game_version() -> String:
	return ProjectSettings.get_setting("application/config/version")

func __get_game_version_pretty() -> String:
	var version: String = ProjectSettings.get_setting("application/config/version")
	match version[-1]:
		"p":
			return "Prototype v%s" % version.trim_suffix("p")
		"a":
			return "Alpha v%s" % version.trim_suffix("a")
		"b":
			return "Beta v%s" % version.trim_suffix("b")
		_ when version[-1].is_valid_int():
			return "v%s" % version
		_:
			push_error("Incorrect game version format in ProjectSettings/application/config/version")
			return ""
