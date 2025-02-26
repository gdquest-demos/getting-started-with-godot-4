extends Control

const Test := preload("test.gd")
const LogEntry := preload("log_entry/log_entry.gd")
const Paths := preload("../paths.gd")
const DB := preload("../db/db.gd")
const Metadata := preload("res://practice_solutions/metadata.gd")

const PracticeMetadata := Metadata.PracticeMetadata

const LogEntryPackedScene := preload("log_entry/log_entry.tscn")

const NAME := "UITestPanel"
const ICON_PATH := "../assets/icons/%s.svg"
const REPORT_STATUS := {
	0: {text = "FAIL", theme_type_variation = &"LabelTesterStatusFail"},
	1: {text = "PASS", theme_type_variation = &"LabelTesterStatusPass"},
}

const REPORT_PHASES = {
	prep = {text = "Setting up the test..."},
	setup_fail = {text = "Test setup failed."},
	checking = {text = "Verifying your practice tasks..."},
	requirements_fail = {text = "Test setup failed."},
	test_fail = {text = "Looks like you've got some things to fix."},
	test_pass = {text = "Congratulations! You aced this practice."},
}

var _practice_info := {}

@onready var metadata: Metadata = get_window().get_node(Metadata.NAME)
@onready var db := DB.new(metadata)

@onready var main_panel_container: PanelContainer = %MainPanelContainer

@onready var item_label: Label = %ItemLabel
@onready var title_label: Label = %TitleLabel

@onready var panel_container_toggle: PanelContainer = %PanelContainerToggle
@onready var status_label: Label = %StatusLabel
@onready var status_animation_player: AnimationPlayer = %StatusAnimationPlayer

@onready var report_texture_rect: TextureRect = %ReportTextureRect
@onready var report_label: Label = %ReportLabel
@onready var input_panel_container: PanelContainer = %InputPanelContainer
@onready var log_v_box_container: VBoxContainer = %LogVBoxContainer

@onready var split_layout: Control = %SplitLayout

@onready var toggle_show_button: Button = %ToggleShowButton
@onready var toggle_x5_button: Button = %ToggleX5Button

@onready var tween: Tween = create_tween()
@onready var custom_minimum_size_x := custom_minimum_size.x
@onready var panel_container_toggle_position_x := panel_container_toggle.position.x


func _ready() -> void:
	var cmdline_args := OS.get_cmdline_args()
	if DisplayServer.get_name() == "headless" or "--script" in cmdline_args or "-s" in cmdline_args:
		queue_free()
		return

	tween.kill()
	toggle_show_button.toggled.connect(_on_toggle_show_button_toggled)

	_prepare_practice_info()
	_report_prep()

	if not _is_practice_scene():
		queue_free()
		return

	_prepare_for_test()
	_report_checking()

	var test := await _setup_test()
	test.setup_requirements()
	if not await _report_requirements(test):
		_restore_from_test(-1)
		return

	await test.setup_checks()
	await test.run()

	var completion := test.get_completion()
	db.update({_practice_info.metadata.id: {completion = completion}})
	db.save()
	_restore_from_test(completion)

	_report_checks(test)
	_report_test(completion)


func _on_toggle_show_button_toggled(is_toggled: bool) -> void:
	const DURATION = 0.1
	tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN)
	if is_toggled:
		toggle_show_button.icon = preload(ICON_PATH % "hide")
		tween.tween_property(self, "custom_minimum_size:x", custom_minimum_size_x, DURATION)
		tween.parallel().tween_property(panel_container_toggle, "position:x", panel_container_toggle_position_x, DURATION)
	else:
		toggle_show_button.icon = preload(ICON_PATH % "show")
		tween.tween_property(self, "custom_minimum_size:x", custom_minimum_size_x + main_panel_container.size.x, DURATION)
		tween.parallel().tween_property(panel_container_toggle, "position:x", 0, DURATION)


func _on_toggle_x5_button_toggled(is_toggled: bool) -> void:
	Engine.set_time_scale(5 if is_toggled else 1)


func _prepare_practice_info() -> void:
	_practice_info.scene = get_tree().current_scene
	_practice_info.file_path = _practice_info.scene.scene_file_path
	_practice_info.dir_name = Paths.get_dir_name(_practice_info.file_path, Paths.PRACTICES_PATH)
	_practice_info.base_path = Paths.PRACTICES_PATH.path_join(_practice_info.dir_name)

	for practice_metadata: PracticeMetadata in metadata.list:
		var path := Paths.to_practice(practice_metadata.packed_scene_path)
		if path == _practice_info.file_path:
			_practice_info.metadata = practice_metadata
			break


func _is_practice_scene() -> bool:
	return (
		_practice_info.file_path.begins_with(Paths.PRACTICES_PATH) and "metadata" in _practice_info
	)


func _prepare_for_test() -> void:
	toggle_x5_button.toggled.connect(_on_toggle_x5_button_toggled)
	input_panel_container.warn()


func _setup_test() -> Test:
	var solution_packed_scene := load(Paths.to_solution(_practice_info.file_path))
	var solution: Node = solution_packed_scene.instantiate()
	split_layout.refresh([_practice_info.scene, solution])

	var test_script := load(Paths.to_solution(_practice_info.base_path).path_join("test.gd"))
	var test: Test = test_script.new()
	add_child(test)
	await test.setup(_practice_info.scene, solution)
	return test


func _restore_from_test(completion: int) -> void:
	status_animation_player.play("default")
	toggle_x5_button.toggled.disconnect(_on_toggle_x5_button_toggled)
	toggle_x5_button.disabled = true
	Engine.time_scale = 1
	if completion == 0:
		input_panel_container.note()
	elif completion == 1:
		input_panel_container.safe()


func _report(info: Dictionary) -> void:
	for node: Control in info:
		for prop: String in info[node]:
			node.set(prop, info[node][prop])


func _report_prep() -> void:
	if not "metadata" in _practice_info:
		return

	status_animation_player.play("testing")
	var pm: PracticeMetadata = _practice_info.metadata
	var info := {}
	info[report_label] = REPORT_PHASES.prep
	info[item_label] = {text = pm.item}
	info[title_label] = {text = pm.title}
	_report(info)


func _report_checking() -> void:
	_report({report_label: REPORT_PHASES.checking})


func _report_checks(test: Test) -> void:
	status_animation_player.play("default")
	for check in test.checks:
		_report_check(check)
		for subcheck in check.subchecks:
			_report_check(subcheck, true)


func _report_check(check: Test.Check, is_subcheck := false) -> void:
	var log_entry := LogEntryPackedScene.instantiate()
	log_v_box_container.add_child(log_entry)

	var has_subchecks := not check.subchecks.is_empty()
	var variation := "check_default"
	match [is_subcheck, has_subchecks, check.status]:
		[true, _, Test.Status.FAIL]:
			variation = "subcheck_fail"
		[true, _, Test.Status.PASS]:
			variation = "subcheck_pass"
		[true, _, Test.Status.DISABLED]:
			variation = "subcheck_default"
		[false, true, Test.Status.FAIL]:
			variation = "check_fail"
		[false, true, Test.Status.PASS]:
			variation = "check_pass"
		[false, false, Test.Status.FAIL]:
			variation = "check_no_subchecks_fail"
		[false, false, Test.Status.PASS]:
			variation = "check_no_subchecks_pass"

	var info: Dictionary = log_entry.get_variation(variation)
	info[log_entry.rich_text_label].merge({text = check.description})
	info[log_entry.extra_rich_text_label].merge({text = check.hint})
	_report(info)


func _report_requirements(test: Test) -> bool:
	var has_passed := true
	for requirement in test.requirements:
		var hint := await requirement.check()
		if not hint.is_empty():
			var log_entry := LogEntryPackedScene.instantiate()
			log_v_box_container.add_child(log_entry)

			var info: Dictionary = log_entry.get_variation("requirement")
			info[log_entry.rich_text_label].merge({text = requirement.description})
			info[log_entry.extra_rich_text_label].merge({text = hint})
			_report(info)
			has_passed = false

	if not has_passed:
		input_panel_container.off()
		_report({report_label: REPORT_PHASES.requirements_fail, status_label: REPORT_STATUS[0]})

	return has_passed


func _report_test(completion: int) -> void:
	var info := {}
	info[status_label] = REPORT_STATUS[completion]
	if completion == 0:
		info[report_label] = REPORT_PHASES.test_fail
		info[report_texture_rect] = {visible = false, texture = preload(ICON_PATH % "fail")}
	else:
		info[report_label] = REPORT_PHASES.test_pass
		info[report_texture_rect] = {visible = true, texture = preload(ICON_PATH % "pass")}
	_report(info)
