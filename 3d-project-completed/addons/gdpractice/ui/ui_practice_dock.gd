@tool
extends PanelContainer

signal metadata_refreshed

const UISelectablePractice := preload("ui_selectable_practice.gd")

const DB := preload("../db/db.gd")
const Build := preload("../build.gd")
const Paths := preload("../paths.gd")
const ThemeUtils := preload("../../gdquest_theme_utils/theme_utils.gd")
const Metadata := preload(Paths.SOLUTIONS_PATH + "/metadata.gd")

const PracticeMetadata := Metadata.PracticeMetadata

const UISelectablePracticePackedScene := preload("ui_selectable_practice.tscn")

const METADATA_PATH := "res://practice_solutions/metadata.gd"

var metadata_modified_time := -1
var build := Build.new()

@onready var list: VBoxContainer = %List
@onready var module_labels: Array[Label] = [%LabelModuleNumber, %LabelModuleName]
@onready var gdquest_logo: BaseButton = %GDQuestLogo


func _ready() -> void:
	gdquest_logo.pressed.connect(OS.shell_open.bind("https://www.gdquest.com/"))
	EditorInterface.get_resource_filesystem().filesystem_changed.connect(construct_panel_list)
	construct_panel_list()
	if not Engine.is_editor_hint() or EditorInterface.get_edited_scene_root() == self:
		return
	theme = ThemeUtils.generate_scaled_theme(theme)
	for control: Control in find_children("", "TextureRect") + find_children("", "TextureButton"):
		control.custom_minimum_size *= EditorInterface.get_editor_scale()


func construct_panel_list() -> void:
	var new_metadata_modified_time = FileAccess.get_modified_time(METADATA_PATH)
	if metadata_modified_time == new_metadata_modified_time:
		return
	metadata_refreshed.emit()
	await get_tree().process_frame

	metadata_modified_time = new_metadata_modified_time
	for ui_selectable_practice: UISelectablePractice in list.get_children():
		ui_selectable_practice.queue_free()

	for metadata: Metadata in get_metadatas():
		if metadata.is_queued_for_deletion() or not "list" in metadata:
			continue

		for practice_metadata: PracticeMetadata in metadata.list:
			var ui_selectable_practice = UISelectablePracticePackedScene.instantiate()
			list.add_child(ui_selectable_practice)
			ui_selectable_practice.setup(practice_metadata)
		set_module_name()
		update()


func get_practice_index(path: String) -> int:
	var result := -1
	if not path.begins_with(Paths.PRACTICES_PATH):
		return result

	path = Paths.to_solution(path)
	var checker := func(p: PackedScene) -> bool: return path == p.resource_path
	for idx in range(list.get_child_count()):
		var ui_selectable_practice: UISelectablePractice = list.get_child(idx)
		if path == ui_selectable_practice.practice_metadata.packed_scene_path:
			result = idx
			break
	return result


func select_practice(scene_root: Node) -> void:
	deselect()
	if scene_root == null or (scene_root != null and scene_root.scene_file_path.is_empty()):
		return
	var index := get_practice_index(scene_root.scene_file_path)
	if index != -1:
		list.get_child(index).select()


func deselect() -> void:
	for ui_selectable_practice in list.get_children():
		ui_selectable_practice.deselect()


func update() -> void:
	for metadata: Metadata in get_metadatas():
		var db := DB.new(metadata)
		for ui_selectable_practice in list.get_children():
			ui_selectable_practice.update(db.progress)


func set_module_name() -> void:
	const SUFFIX := "(Workbook)"
	var project_name: String = ProjectSettings.get_setting("application/config/name")
	if not project_name.is_empty():
		var module_info := project_name.replace(SUFFIX, "").strip_edges().split(".")
		var module_info_size := module_info.size()
		if module_info_size != module_labels.size():
			return

		for idx in range(module_info_size):
			module_labels[idx].text = ("%s." % module_info[idx]) if idx == 0 else module_info[idx]


func get_metadatas() -> Array:
	var predicate := func(n: Node) -> bool: return n is Metadata
	return get_window().get_children().filter(predicate)
