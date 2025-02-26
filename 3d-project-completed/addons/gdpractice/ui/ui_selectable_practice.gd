## UI component for one practice.
@tool
extends MarginContainer

const Build := preload("../build.gd")
const Paths := preload("../paths.gd")
const DB := preload("../db/db.gd")
const Progress := preload("../db/progress.gd")
const ThemeUtils := preload("../../gdquest_theme_utils/theme_utils.gd")
const Utils := preload("../../gdquest_sparkly_bag/sparkly_bag_utils.gd")
const Metadata := preload(Paths.SOLUTIONS_PATH + "/metadata.gd")

const PracticeMetadata := Metadata.PracticeMetadata

const DEFAULT_VARIATION := &"MarginContainerPractice"
const SELECTED_VARIATION := &"MarginContainerSelectedPractice"

const COLOR_DISABLED_TEXT := Color(0.51764708757401, 0.59607845544815, 0.74509805440903)
const CHECKBOX_TEXTURES := {
	false: preload("../assets/checkbox_empty.svg"),
	true: preload("../assets/checkbox_ticked.svg"),
}

static var button_group := ButtonGroup.new()
static var build := Build.new()

var practice_metadata: PracticeMetadata = null

@onready var label_item: Label = %LabelItem
@onready var label_title: Label = %LabelTitle
@onready var button: Button = %Button
@onready var reset_button: Button = %ResetButton
@onready var run_button: Button = %RunButton
@onready var icon_checkbox: TextureRect = %IconCheckbox
@onready var run_button_container: VBoxContainer = %RunButtonContainer
@onready var reset_confirmation_dialog: ConfirmationDialog = %ResetConfirmationDialog
@onready var reset_accept_dialog: AcceptDialog = %ResetAcceptDialog


func _ready() -> void:
	button.button_group = button_group
	button.pressed.connect(open)
	run_button.pressed.connect(EditorInterface.play_current_scene)
	reset_button.pressed.connect(reset_confirmation_dialog.set_visible.bind(true))
	var reset_ok_button := reset_confirmation_dialog.get_ok_button()
	reset_ok_button.pressed.connect(reset_practice)

	if not Engine.is_editor_hint() or EditorInterface.get_edited_scene_root() == self:
		return

	theme = ThemeUtils.generate_scaled_theme(theme)
	for control: Control in find_children("", "TextureRect") + find_children("", "TextureButton"):
		control.custom_minimum_size *= EditorInterface.get_editor_scale()

	for dialog: AcceptDialog in find_children("", "AcceptDialog"):
		dialog.size *= EditorInterface.get_editor_scale()

	for button: Button in [
		reset_ok_button,
		reset_confirmation_dialog.get_cancel_button(),
		reset_accept_dialog.get_ok_button(),
	]:
		button.theme_type_variation = "ButtonRun"
		button.custom_minimum_size = Vector2(160, 0) * EditorInterface.get_editor_scale()


func setup(practice_metadata: PracticeMetadata) -> void:
	self.practice_metadata = practice_metadata
	label_title.text = practice_metadata.title
	label_item.text = practice_metadata.item
	reset_confirmation_dialog.dialog_text %= practice_metadata.id
	reset_accept_dialog.dialog_text %= practice_metadata.id


## Makes this selected, pressing the child button node and emitting the pressed signal.
func select() -> void:
	button.set_pressed_no_signal(true)
	theme_type_variation = SELECTED_VARIATION
	reset_button.visible = true
	run_button_container.visible = true


func deselect() -> void:
	button.set_pressed_no_signal(false)
	theme_type_variation = DEFAULT_VARIATION
	var practice_packed_scene_path := Paths.to_practice(practice_metadata.packed_scene_path)
	reset_button.visible = not FileAccess.file_exists(practice_packed_scene_path)
	run_button_container.visible = false


func update(progress: Progress) -> void:
	if not practice_metadata.id in progress.state:
		return
	icon_checkbox.texture = CHECKBOX_TEXTURES[progress.state[practice_metadata.id].completion == 1]


func open() -> void:
	var practice_scene_path = Paths.to_practice(practice_metadata.packed_scene_path)
	if FileAccess.file_exists(practice_scene_path):
		EditorInterface.open_scene_from_path(practice_scene_path)
		await get_tree().process_frame
		select()
	else:
		var msg := "Practice (id=%s) not found at '%s'"
		push_warning(msg % [practice_metadata.id, practice_scene_path])


func reset_practice() -> void:
	var predicate := func(n: Node) -> bool: return n is Metadata
	for metadata: Metadata in get_window().get_children().filter(predicate):
		var db := DB.new(metadata)
		if not practice_metadata.id in db.progress.state:
			db.progress.state[practice_metadata.id] = {}

		db.progress.state[practice_metadata.id].completion = 0
		db.save()

		var solution_dir_name := Paths.get_dir_name(practice_metadata.packed_scene_path)
		if solution_dir_name.is_empty():
			continue

		build.build_practice(solution_dir_name, true)
		update(db.progress)
		reset_accept_dialog.visible = true
		reset_button.visible = false

		EditorInterface.get_resource_filesystem().scan()
		while EditorInterface.get_resource_filesystem().is_scanning():
			pass

		var practice_scene_paths := Utils.fs_find(
			"*.tscn", Paths.to_practice(practice_metadata.packed_scene_path.get_base_dir())
		).result
		var open_scene_paths := EditorInterface.get_open_scenes()
		for practice_scene_path in practice_scene_paths:
			if practice_scene_path in open_scene_paths:
				EditorInterface.reload_scene_from_path(practice_scene_path)
		EditorInterface.get_script_editor().notification(NOTIFICATION_APPLICATION_FOCUS_IN)
