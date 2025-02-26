@tool
extends EditorPlugin

const Paths := preload("paths.gd")
const UITestPanel := preload("tester/ui_test_panel.gd")
const UIPracticeDock := preload("ui/ui_practice_dock.gd")
const UISolutionWarning := preload("ui/ui_solution_warning.gd")
const Utils := preload("../gdquest_sparkly_bag/sparkly_bag_utils.gd")
const Metadata := preload(Paths.SOLUTIONS_PATH + "/metadata.gd")

const PracticeMetadata := Metadata.PracticeMetadata

const UIPracticeDockPackedScene := preload("ui/ui_practice_dock.tscn")
const UISolutionWarningPackedScene := preload("ui/ui_solution_warning.tscn")

const TEMPLATES_DIR := "script_templates/Test"

const AUTOLOADS := {
	UITestPanel.NAME: "tester/ui_test_panel.tscn",
	Metadata.NAME: Paths.SOLUTIONS_PATH + "/metadata.gd"
}

var editor_run_bar: MarginContainer = null
var ui_practice_dock: UIPracticeDock = null
var ui_solution_warning: UISolutionWarning = null
var quick_open_trees: Array[Tree] = []
var picker_quick_open_trees: Array[Tree] = []
var filesystem_dock_trees: Array[Tree] = []


func _enter_tree() -> void:
	var base_control := EditorInterface.get_base_control()
	if Paths.SOLUTIONS_PATH.begins_with("res://addons"):
		filesystem_dock_trees.assign(EditorInterface.get_file_system_dock().find_children("", "Tree", true, false))
		var predicate := func(e: ConfirmationDialog) -> bool: return not e.get_parent() is EditorResourcePicker
		var quick_opens: Array[Node] = base_control.find_children("", "EditorQuickOpen", true, false).filter(predicate)
		for quick_open: ConfirmationDialog in quick_opens:
			quick_open_trees.append_array(quick_open.find_children("", "Tree", true, false))

	for key: String in AUTOLOADS.keys():
		add_autoload_singleton(key, AUTOLOADS[key])

	scene_changed.connect(_on_scene_changed)

	for control: MarginContainer in base_control.find_children("", "EditorRunBar", true, false):
		editor_run_bar = control

	ui_practice_dock = UIPracticeDockPackedScene.instantiate()
	ui_practice_dock.metadata_refreshed.connect(_on_ui_practice_dock_metadata_refreshed)
	editor_run_bar.stop_pressed.connect(ui_practice_dock.update)
	scene_changed.connect(ui_practice_dock.select_practice)
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, ui_practice_dock)

	ui_solution_warning = UISolutionWarningPackedScene.instantiate()
	EditorInterface.get_editor_main_screen().add_child(ui_solution_warning)

	# Removed for now because this should not happen to the user's project. It's a tool for teachers creating practices.
	# add_templates()


func _exit_tree() -> void:
	# remove_templates()

	editor_run_bar.stop_pressed.disconnect(ui_practice_dock.update)
	scene_changed.disconnect(ui_practice_dock.select_practice)

	remove_control_from_docks(ui_practice_dock)

	ui_practice_dock.queue_free()
	ui_solution_warning.queue_free()

	for key: String in AUTOLOADS:
		remove_autoload_singleton(key)


func _process(_delta: float) -> void:
	hide_solutions()


func _on_scene_changed(scene_root: Node) -> void:
	var is_solution := scene_root != null
	is_solution = is_solution and scene_root.scene_file_path.begins_with(Paths.SOLUTIONS_PATH)
	ui_solution_warning.visible = is_solution
	if not is_solution:
		return

	var solution_file_path := scene_root.scene_file_path
	var solution_dir_path := solution_file_path.get_base_dir()
	var is_solution_predicate := func(m: PracticeMetadata) -> bool: return (
		m.packed_scene_path.begins_with(solution_dir_path)
	)

	var is_metadata_predicate := func is_metadata(n: Node) -> bool: return n is Metadata
	for metadata: Metadata in get_window().get_children().filter(is_metadata_predicate):
		for pm: PracticeMetadata in metadata.list.filter(is_solution_predicate):
			ui_solution_warning.set_text(
				solution_file_path, Paths.to_practice(pm.packed_scene_path), pm.full_title
			)


func _on_ui_practice_dock_metadata_refreshed() -> void:
	remove_autoload_singleton.call_deferred(Metadata.NAME)
	add_autoload_singleton.call_deferred(Metadata.NAME, AUTOLOADS[Metadata.NAME])


func _on_resource_picker_id_pressed(id: int, resource_picker: EditorResourcePicker) -> void:
	if id != 1:
		return

	for quick_open: ConfirmationDialog in resource_picker.find_children("", "EditorQuickOpen", false, false):
		picker_quick_open_trees.assign(quick_open.find_children("", "Tree", true, false))


## Copies practice template scripts to the project root directory.
func add_templates() -> void:
	var plugin_dir_path: String = get_script().resource_path.get_base_dir()
	var plugin_template_dir_path := plugin_dir_path.path_join(TEMPLATES_DIR)
	var found := Utils.fs_find("*.gd", plugin_template_dir_path)
	if found.return_code != Utils.ReturnCode.OK:
		return

	for plugin_template_file_path: String in found.result:
		var root_template_file_path = Paths.RES.path_join(TEMPLATES_DIR).path_join(
			plugin_template_file_path.get_file()
		)
		if (
			FileAccess.file_exists(root_template_file_path)
			and (
				FileAccess.get_modified_time(plugin_template_file_path)
				< FileAccess.get_modified_time(root_template_file_path)
			)
		):
			continue

		DirAccess.make_dir_recursive_absolute(root_template_file_path.get_base_dir())
		DirAccess.copy_absolute(plugin_template_file_path, root_template_file_path)


## Removes practice template scripts from the project.
func remove_templates() -> void:
	var templates_base_dir_path := Paths.RES.path_join(TEMPLATES_DIR.get_base_dir())
	Utils.fs_remove_dir(Paths.RES.path_join(TEMPLATES_DIR))
	if Utils.fs_find("*", templates_base_dir_path).result.is_empty():
		Utils.fs_remove_dir(templates_base_dir_path)


func hide_solutions() -> void:
	for tree in quick_open_trees + picker_quick_open_trees:
		var is_valid := is_instance_valid(tree)
		if not is_valid or (is_valid and not tree.is_inside_tree()):
			continue

		var item := tree.get_root()
		while item != null:
			item.visible = not item.get_text(0).begins_with("addons")
			item = item.get_next_in_tree()

	for tree in filesystem_dock_trees:
		if not tree.is_inside_tree():
			continue

		var is_done := false
		var item := tree.get_root()
		while item != null and not is_done:
			var parent := item.get_parent()
			if (
				item.get_text(0).begins_with("addons")
				and parent != null
				and parent.get_text(0) == "res://"
			):
				item.visible = false
				is_done = true
			item = item.get_next_in_tree()

	var resource_pickers := EditorInterface.get_inspector().find_children(
		"", "EditorResourcePicker", true, false
	)
	for resource_picker: EditorResourcePicker in resource_pickers:
		var popup_menus := resource_picker.find_children("", "PopupMenu", true, false)
		for popup_menu: PopupMenu in popup_menus:
			if not popup_menu.id_pressed.is_connected(_on_resource_picker_id_pressed):
				popup_menu.id_pressed.connect(_on_resource_picker_id_pressed.bind(resource_picker))
