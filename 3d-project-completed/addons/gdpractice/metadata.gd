## Base class for registering practices and their metadata in a project.
## Create a file res://practice_solutions/metadata.gd in your project and append PracticeMetadata objects to the [member list] property to define and register practices in your project.
@tool
extends Node

const Paths := preload("paths.gd")

const NAME := "Metadata"

## Represents the metadata of a given practice.
## You need to create these objects and append them to the list property in your project's metadata.gd file.
class PracticeMetadata:
	var _cache := {}
	var _dir_name_regex := RegEx.create_from_string(r"^L(\d+)\.P(\d+)(\..+)?$")

	var lesson_number := 0
	var practice_number := 0
	var packed_scene_path := ""
	var item := ""
	var full_title := ""

	var id := ""
	var title := ""
	var packed_scene: PackedScene = null

	func _init(id: String, title: String, packed_scene: PackedScene) -> void:
		self.id = id
		self.title = title
		self.packed_scene = packed_scene

		packed_scene_path = packed_scene.resource_path
		var dir_name := Paths.get_dir_name(packed_scene_path)
		var regex_match := _dir_name_regex.search(dir_name)
		if regex_match == null:
			printerr("Invalid practice directory name: %s. It should have the form LX.PX, or LX.PX.folder_name. For example, L4.P2.practice_name" % dir_name)
		lesson_number = regex_match.strings[1].to_int()
		practice_number = regex_match.strings[2].to_int()
		item = "L%d.P%d" % [lesson_number, practice_number]
		full_title = "%s %s" % [item, title]

	func _to_string() -> String:
		return str(to_dictionary())

	func to_dictionary(exclude: Array[String] = ["@*", "_*"]) -> Dictionary:
		if "dictionary" in _cache:
			return _cache.dictionary

		var result := inst_to_dict(self)
		var predicate := func(k: String) -> bool: return exclude.any(
			func(e: String) -> bool: return k.match(e)
		)

		for key in result.keys().filter(predicate):
			result.erase(key)

		_cache.dictionary = result
		return result

## Create and store practice metadata objects in here to register practices.
var list: Array[PracticeMetadata] = []
