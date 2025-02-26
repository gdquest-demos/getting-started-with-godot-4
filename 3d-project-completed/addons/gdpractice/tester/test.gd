## This class is used by [b]instructors[/b] to validate practices based on a direct comparisson
## with the solution.
extends Node


class Requirement:
	var description := ""
	var checker: Callable = func() -> String: return ""
	var params := []

	func check() -> String:
		return await checker.callv(params)


class Check:
	var cache := {}

	var description := ""
	var hint := ""
	var status := Status.DISABLED

	var checker := func() -> String: return ""
	var dependencies: Array[Check] = []
	var subchecks: Array[Check] = []


	func is_disabled() -> bool:
		if "is_disabled" in cache:
			return cache.is_disabled

		var result := false
		# This check is disabled if any of its dependencies is disabled or has not passed.
		for dependency: Check in dependencies:
			if "is_disabled" in dependency.cache and dependency.cache.is_disabled:
				result = true
				break

			if not await dependency.has_passed():
				result = true
				break

		cache.is_disabled = result
		return result

	func has_passed() -> bool:
		if "has_passed" in cache:
			return cache.has_passed

		hint = checker.call()
		var result := hint.is_empty()
		if result:
			for subcheck: Check in subchecks:
				await subcheck.run()
				result = subcheck.status == Status.PASS
				if not result:
					break

		cache.has_passed = result
		return result

	func run() -> void:
		var is_disabled := await is_disabled()
		status = (
			Status.DISABLED if is_disabled else (Status.PASS if await has_passed() else Status.FAIL)
		)


const Paths := preload("../paths.gd")
const Utils := preload("../../gdquest_sparkly_bag/sparkly_bag_utils.gd")

## Functions that have names beginning with this string will be called in [method run]
## automatically.
const COMMENT_REGEX := "#.*$"

enum Status { DISABLED, PASS, FAIL }

var checks: Array[Check] = []
var requirements: Array[Requirement] = []

## Used to store [b]practice[/b] and [b]solution[/b] as well as any needed extra data for
## testing with the framework. It needs to be populated before use.
var _test_space := []

var _practice_base_path := ""

## Simplified [b]practice[/b] code split line by line as [Array] of [String].
var _practice_code: Array[String] = []

## The [b]practice[/b] scene.
var _practice: Node = null

## The [b]solution[/b] scene.
var _solution: Node = null


## Sets up references to the practice and solution scenes and awaits: [br]
## - [i]virtual[/i] [method _setup_state]: to update the solution state based on the practice
## initial conditions. [br]
## - [i]virtual[/i] [method _setup_populate_test_space]: to acquire state for comparisson between
## practice and solution scenes.
##
## These [code]_setup_*()[/code] methods are helpers for breaking the tasks into smaller chunks.
func setup(practice: Node, solution: Node) -> void:
	# We wait for 1 frame to ensure the practice scene had the time to get ready.
	# Without that, state immediately gathered in _setup_state() will not be accurate.
	await get_tree().process_frame

	_practice = practice
	_solution = solution

	var _practice_script: Script = _practice.get_script()
	if _practice_script != null:
		_practice_base_path = _practice_script.resource_path.get_base_dir()
		_practice_code = _preprocess_practice_code(_practice_script)


func setup_requirements() -> void:
	_build_requirements()


func setup_checks() -> void:
	await _setup_state()
	await _setup_populate_test_space()
	_build_checks()


func run() -> void:
	for check in checks:
		check.run()


func get_completion() -> int:
	return 0 if checks.any(func(c: Check) -> bool: return c.status != Status.PASS) else 1


func _build_requirements() -> void:
	pass


func _build_checks() -> void:
	pass


## Assign here the [b]practice[/b] state to the [b]solution[/b] state so they both start with the
## same initial conditions.
func _setup_state() -> void:
	pass


## Acquire both [b]practice[/b] and [b]solution[/b] state data for test validation.
func _setup_populate_test_space() -> void:
	pass


func _add_simple_check(description: String, checker) -> Check:
	var check := Check.new()
	check.description = description
	check.checker = checker
	checks.push_back(check)
	return check


func _add_actions_requirement(actions: Array) -> void:
	var requirement := Requirement.new()
	requirement.description = tr("Missing input actions")
	requirement.checker =  func() -> String:
		var result := []
		for action: StringName in actions:
			if not InputMap.has_action(action):
				result.push_back("[b]%s[/b]" % action)
		return "" if result.is_empty() else " ".join([tr("Your Godot project is missing the input actions"), "%s," % ", ".join(result), tr("but they're needed for the practice to work. If you ran this practice before completing the corresponding lesson, please follow along the lesson first.")])
	requirements.push_back(requirement)


func _add_callable_requirement(description: String, checker: Callable, params := []) -> void:
	var requirement := Requirement.new()
	requirement.description = description
	requirement.checker = checker
	requirement.params = params
	requirements.push_back(requirement)


## Adds a requirement to the list of requirements that checks if the given [param properties] are present in the [param object].
func _add_properties_requirement(properties: Array[String], object: Object = _practice) -> void:
	var requirement := Requirement.new()
	requirement.description = tr("Missing properties")
	requirement.checker = func check_properties() -> String:
		var missing_properties := []
		for prop_name: String in properties:
			if not prop_name in object:
				missing_properties.append(prop_name)
		if not missing_properties.is_empty():
			var property_list := ", ".join(missing_properties)
			var property_word := tr("properties") if missing_properties.size() > 1 else tr("property")
			return tr("%s is missing the %s %s. Did you remove it from the script?") % [object.name, property_list, property_word]
		return ""
	requirements.push_back(requirement)


## Connects [param callback] to [param sig] signal for the given amount of [param time] by waiting
## for [signal SceneTreeTimer.timeout] and disconnecting at the end.
func _connect_timed(time: float, sig: Signal, callback: Callable) -> void:
	sig.connect(callback)
	await get_tree().create_timer(time).timeout
	sig.disconnect(callback)


## Returns [code]true[/code] if a line in the input [code]code[/code] matches one of the
## [param target_lines]. Uses [method String.match] to match lines, so you can use
## [code]?[/code] and [code]*[/code] in [param target_lines].
func _is_code_line_match(target_lines: Array) -> bool:
	for line in _practice_code:
		for match_pattern in target_lines:
			if line.match(match_pattern):
				return true
	return false


## Retruns [code]true[/code] if the [param success_predicate] [Callable] returns [code]true[/code] for all
## pairs of consecutive items in [member _test_space]. Otherwise it returns [code]false[/code].
##
## Parameters:
##
## - [param success_predicate] is a [Callable] that expects a pair of parameters fed from
## [member _test_space].
func _is_sliding_window_pass(success_predicate: Callable) -> bool:
	var result := true
	var x = _test_space[0]
	for y in _test_space.slice(1):
		if not success_predicate.call(x, y):
			result = false
			break
		x = y
	return result


## Set [param property_path] to [param value] for both [member _practice] and [member _solution].
## If [param property_path] base name (index [code]0[/code] of the [NodePath]) isn't found in
## [member _practice] or [member _solution] push an error to the debugger that it failed to set
## the [param value].[br]
## [br]
## Say for example we have a scene with a [TextEdit] node referenced by the [code]text_edit[/code]
## variable in code. Then we can call this function to set a property on [code]text_edit[/code]
## for both [b]practice[/b] and [b]solution[/b] scenes like this:
##
## [codeblock]
## var input := "world"
## _set_all("text_edit:text", input)
## [/codeblock]
##
## Known issues or limitations:[br]
## - If [param property_path] referes to a non-existing deep-nested property, the function
## does nothing and reports no errors.
func _set_all(property_path: NodePath, value: Variant) -> void:
	if property_path.is_empty():
		push_error("Can't set empty property path with value %s." % value)
		return

	for node in [_practice, _solution]:
		var property_name := property_path.get_name(0)
		if not property_name in node:
			push_error(
				(
					"Error setting property '%s.%s' with value '%s'. Property not found."
					% [node, property_name, value]
				)
			)
		node.set_indexed(property_path, value)


## Calls [param method] with [param arg_array] using [method Object.callv] on both
## [member _practice] and [member _solution]. Returns the result of the [param method] calls
## as a [Dictionary] with keys [code]practice[/code]
## and [code]solution[/code].
func _call_all(method: String, arg_array: Array = []) -> Dictionary:
	return {
		practice = _practice.callv(method, arg_array), solution = _solution.callv(method, arg_array)
	}


## Helper to simplify the [b]practice[/b] script code. It returns the simplified code split
## line by line as [Array] of [String].
static func _preprocess_practice_code(practice_script: Script) -> Array[String]:
	var result: Array[String] = []
	var comment_suffix := RegEx.new()
	comment_suffix.compile(COMMENT_REGEX)
	for line in practice_script.source_code.split("\n"):
		line = line.strip_edges().replace(" ", "")
		if not (line.is_empty() or line.begins_with("#")):
			result.push_back(comment_suffix.sub(line, ""))
	return result


func _load(pattern: String, is_practice := true) -> Resource:
	var result: Resource = null
	var path: String = get_script().resource_path.get_base_dir()
	if is_practice:
		path = Paths.to_practice(path)

	var file_paths := Utils.fs_find(pattern, path).result
	var error_message := ""
	if file_paths.is_empty():
		error_message = "Couldn't find '%s' in '%s'" % [pattern, path]
	elif file_paths.size() > 1:
		error_message = "Found more than one file with name '%s': %s" % [pattern, file_paths]
	else:
		for file_path in file_paths:
			result = load(file_path)

	assert(error_message.is_empty(), error_message)
	return result
