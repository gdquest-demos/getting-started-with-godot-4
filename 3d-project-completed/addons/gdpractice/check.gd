extends SceneTree

const Paths := preload("paths.gd")
const Test := preload("tester/test.gd")
const Utils := preload("../gdquest_sparkly_bag/sparkly_bag_utils.gd")
const Metadata := preload(Paths.SOLUTIONS_PATH + "/metadata.gd")

const PracticeMetadata := Metadata.PracticeMetadata
const Check := Test.Check
const Status := Test.Status
const Result := Utils.Result
const ReturnCode := Utils.ReturnCode

const TEST_FILE_NAME := "test.gd"


func _init() -> void:
	print_rich("[color=blue]Checking scene instantiation...[/color]")
	var predicate = func(p: String): return not p.begins_with("%spractice" % Paths.RES)
	for scene_path in Utils.fs_find("*.tscn", Paths.RES, false).result.filter(predicate):
		var message := "%s instance check..." % scene_path
		if load(scene_path) == null:
			push_error("%sFAIL" % message)
			quit()
		else:
			print_rich("%s[color=green]PASS[/color]" % message)
	print()

	var metadata := Metadata.new()
	for practice_metadata: PracticeMetadata in metadata.list:
		var solution_scene_path := practice_metadata.packed_scene_path
		var practice_scene_path := Paths.to_practice(solution_scene_path)

		print_rich("[color=blue]%s[/color]" % Paths.get_dir_name(solution_scene_path))
		for node in root.get_children():
			node.queue_free()

		var path_groups: Array[Array] = [
			[solution_scene_path, solution_scene_path], [practice_scene_path, solution_scene_path]
		]
		for paths in path_groups:
			print_rich("Checking %s VS %s..." % paths)
			var messages := await check_test(paths.front(), paths.back())
			if not messages.is_empty():
				push_warning(join_warnings(messages))
		print()
	quit()


func check_test(practice_scene_path: String, solution_scene_path: String) -> Array[String]:
	var result: Array[String] = []
	var message := "file '%s' not found."
	if not FileAccess.file_exists(solution_scene_path):
		return [message % solution_scene_path]

	if practice_scene_path.is_empty():
		practice_scene_path = solution_scene_path

	var packed_scenes: Array[PackedScene] = []
	for scene_path: String in [practice_scene_path, solution_scene_path]:
		if scene_path.is_empty():
			continue

		var packed_scene: PackedScene = load(scene_path)
		if packed_scene == null:
			return [message % scene_path]
		packed_scenes.push_back(packed_scene)

	var test_file_path := solution_scene_path.get_base_dir().path_join(TEST_FILE_NAME)
	if not FileAccess.file_exists(test_file_path):
		return [message % test_file_path]

	message = "'%s' couldn't be loaded."
	var test_script: GDScript = load(test_file_path)
	if test_script == null:
		return [message % test_file_path]

	var test: Test = test_script.new()
	root.add_child.call_deferred(test)
	await test.ready

	var scenes: Array[Node] = []
	for packed_scene in packed_scenes:
		var scene := packed_scene.instantiate()
		scenes.push_back(scene)
		root.add_child.call_deferred(scene)
		await scene.ready

	await test.setup(scenes.front(), scenes.back())
	test.setup_requirements()
	message = "requirement '%s' failed for '%s'."
	for requirement in test.requirements:
		var hint := await requirement.check()
		if not hint.is_empty():
			result.push_back(message % [hint, test_file_path])

	await test.setup_checks()
	await test.run()
	var checks := test.checks.map(func(c: Check) -> Array: return [c] + c.subchecks)
	for check in Utils.flatten(checks):
		message = get_check_status_message(check, solution_scene_path == practice_scene_path)
		if not message.is_empty():
			result.push_back(message % test_file_path)
	return result


func get_check_status_message(check: Check, is_solution: bool) -> String:
	var result := ""
	var is_practice := not is_solution
	var has_failed := is_solution and check.status == Status.FAIL
	has_failed = (
		has_failed or (is_practice and not check.status in [Status.FAIL, Status.DISABLED])
	)
	if has_failed:
		result = "'%%s' check '%s' failed." % check.description
	return result


func join_warnings(messages: Array) -> String:
	return "\n  " + "\n  ".join(messages)
