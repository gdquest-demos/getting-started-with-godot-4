## Build script that converts solutions into practices and optionally generates Godot project folders for course modules.
##
## [b]Usage[/b]:
## [codeblock]
## godot --headless --script addons/gdquest_practice_framework/build.gd -- arg1 arg2 ...
## [/codeblock]
##
## Run with [code]--help[/code] to see the available arguments.
##
## [b]Generating practice starting files with the build script[/b]:
##
## The build script also processes practice code lines by replacing them with the given
## comments at the end of the line in [b]GDScript[/b] files.
##
## [codeblock]
## position += delta * velocity # position
## [/codeblock]
##
## Results in the following practice code:
##
## [codeblock]
## position
## [/codeblock]
##
## In some cases we want to remove the line completely for more complex code. Empty comments at
## the end of the line result in deletion of the line in the practice GDScript file.
##
## Furthermore, we can use a special syntax like [code]# >[/code] and [code]# <[/code] to indent
## and respectively dedent the given line of code in the practice script, otherwise the indentation
## is preserved:
##
## [codeblock]
## func generate_gems(columns: int, rows: int) -> void:
##     # Add two nested loops to generate cell coordinates.
##     # Generate the columns with the first loop and the rows with the second.
##
##     # You'll need to indent the lines below to be inside the inner loop block.
##     # You can select the lines with the mouse and press Tab to do so.
##     # Update the cell value to represent the cell coordinates on each loop iteration.
##     for column in range(columns): #
##         for row in range(rows): #
##             var cell := Vector2(column, row) # << var cell := Vector2(0, 0)
##             generate_one_gem(cell) # << generate_one_gem(cell)
## [/codeblock]
##
## Results in the following practice code:
##
## [codeblock]
## func generate_gems(columns: int, rows: int) -> void:
##     # Add two nested loops to generate cell coordinates.
##     # Generate the columns with the first loop and the rows with the second.
##
##     # You'll need to indent the lines below to be inside the inner loop block.
##     # You can select the lines with the mouse and press Tab to do so.
##     # Update the cell value to represent the cell coordinates on each loop iteration.
##     var cell := Vector2(0, 0)
##     generate_one_gem(cell)
## [/codeblock]
##
## [b]Note[/b] that:
##
## [b]Note[/b] that: [br]
##
## - Only-comment lines are also preserved in the practice. [br]
## - The special [code]<[/code] and [code]>[/code] symbols can be repeated multiple times. [br]
extends SceneTree

const Paths := preload("paths.gd")
const Utils := preload("../gdquest_sparkly_bag/sparkly_bag_utils.gd")
const BuildSettings := preload("build_settings.gd")

const PROJECT_FILE := "project.godot"
const PLUGINS_SECTION := "editor_plugins"
const AUTOLOAD_SECTION := "autoload"
const APP_SECTION := "application"
const APP_NAME_KEY := "config/name"
const RUN_MAIN_SCENE_KEY := "run/main_scene"
const REPLACE_EXTS := ["gd", "tscn", "tres", "cfg"]
const GODOT_EXE := "godot"


const DENTS := {"<": -1, ">": 1}
const LOG_MESSAGE := "\t%s...%s"

const ReturnCode = Utils.ReturnCode

var regex_line := RegEx.create_from_string(r"^(\h*)(.*)#\h*(.*)$")
var regex_shift := RegEx.create_from_string(r"^([<>]+)\h*(.*)")
var regex_uid := RegEx.create_from_string(r'\s*uid=".*?"')


func _init() -> void:
	const ARG_GENERATE_PROJECT_WORKBOOK := ["-w", "--generate-project-workbook", "Generates a Godot project folder for the lesson module and practices start files."]
	const ARG_GENERATE_PROJECT_SOLUTIONS := ["-s", "--generate-project-solutions", "Generates a Godot project folder for the practice module."]
	const ARG_PRACTICES := ["-p", "--generate-practices", "Generates practice files from solutions within this project (for development)."]

	var cmdline_args := OS.get_cmdline_args()
	var args := {}
	var user_args := []
	if "--script" in cmdline_args or "-s" in cmdline_args:
		var parsed := Utils.os_parse_user_args([
			"Build script that converts solutions into practices and optionally generates Godot project folders for course modules.",
			"Note: The script must be run from the root folder of the Godot project.",
			"",
			"Usage:",
			"",
			"[color=yellow]godot --headless --script addons/gdquest_practice_framework/build.gd -- ARG ...[ARGS][/color]",
			"",
			"Where ARG & ARGS refer to one of the Arguments below. Multiple Arguments can be given, but at least one is necessary.",
			"",
		], [
			ARG_GENERATE_PROJECT_WORKBOOK,
			ARG_GENERATE_PROJECT_SOLUTIONS,
			ARG_PRACTICES,
			["-o", "--output-path", "Output directory path."],
			["--do-disable-plugins", "Disable plugins."],
			["--do-project-diff", "Run project() function from practice_solutions/diff.gd if available."],
		])
		user_args = parsed.result.user_args
		args = parsed.result.args
		if args.is_empty():
			quit()
			return

		if not ("-o" in args or "--output-path" in args):
			args["--output-path"] = ""
		elif "-o" in args:
			args["--output-path"] = args["-o"]

	var build_settings_path := Paths.SOLUTIONS_PATH.path_join("build_settings.gd")
	var build_settings: BuildSettings = null
	if FileAccess.file_exists(build_settings_path):
		var script: GDScript = load(build_settings_path)
		var instance = script.new()
		if instance is not BuildSettings:
			push_error(
				"Found build settings script at path '%s' but it does not extend 'BuildSettings' It should extend '%s'. Ignoring build settings."
				% [build_settings_path, (BuildSettings as GDScript).resource_path]
			)
		else:
			build_settings = instance

	var return_code := ReturnCode.OK
	var exclude_patterns: Array[String] = ["*.godot/*", "*.plugged/*", "res://.git*", "*plug.gd", "*makefile"]
	for key in args:
		if key in ARG_GENERATE_PROJECT_WORKBOOK:
			var exclude_patterns_workbook := exclude_patterns.duplicate()
			if build_settings != null:
				exclude_patterns_workbook.append_array(build_settings.workbook_exclude_patterns)
			return_code = build_project("workbook", args["--output-path"], exclude_patterns_workbook)

		if key in ARG_GENERATE_PROJECT_SOLUTIONS:
			var exclude_patterns_solutions: Array[String] = exclude_patterns.duplicate()
			exclude_patterns_solutions.append_array(["*test.gd", "*diff.gd", "*practice_solutions/metadata.gd"])
			if build_settings != null:
				exclude_patterns_solutions.append_array(build_settings.solution_exclude_patterns)
			return_code = build_project("solutions", args["--output-path"], exclude_patterns_solutions)

		if key in ARG_PRACTICES:
			var do_disable_plugins := "--do-disable-plugins" in user_args
			var do_project_diff := "--do-project-diff" in user_args
			return_code = build_practices(do_disable_plugins, do_project_diff)

		if return_code != ReturnCode.OK:
			break

	if return_code != ReturnCode.OK:
		push_error("FAIL")
	quit(return_code)


func build_project(suffix: String, output_path: String, exclude_patterns: Array[String] = []) -> ReturnCode:
	var return_code := ReturnCode.OK

	# Preparing paths for copying files.
	var plugin_dir_path: String = get_script().resource_path.get_base_dir()
	var solution_dir_path := plugin_dir_path.path_join(Paths.SOLUTIONS_PATH.get_file())

	var source_project_dir_path := ProjectSettings.globalize_path(Paths.RES).get_base_dir()
	var source_solutions_dir_path := ProjectSettings.globalize_path(Paths.SOLUTIONS_PATH)
	var destination_project_dir_path := "%s_%s" % [source_project_dir_path, suffix] if output_path == "" else output_path.path_join("%s_%s" % [source_project_dir_path.get_file(), suffix])
	var destination_plugin_dir_path := ProjectSettings.globalize_path(plugin_dir_path).replace(
		source_project_dir_path, destination_project_dir_path
		)

	var addons_dir_path := Paths.RES.path_join("addons")
	var addons_to_exclude := ["gd-plug", "gdpractice", "gdquest_theme_utils", "gdquest_sparkly_bag"]
	var lessons_dir_path := Paths.RES.path_join("lessons/")
	var lessons_reference_dir_path := Paths.RES.path_join("lessons_reference")
	var script_templates_dir_path := Paths.RES.path_join("script_templates")
	var path_starts_to_exclude := [Paths.PRACTICES_PATH, script_templates_dir_path]

	# Finding files to copy.
	var should_be_copied_predicate := func(path: String) -> bool:
		var addons_folders_to_exclude := []
		for addon_name: String in addons_to_exclude:
			addons_folders_to_exclude.append(addons_dir_path.path_join(addon_name))
		return not (
			(path_starts_to_exclude + (
				addons_folders_to_exclude + [lessons_dir_path] if suffix == "solutions"
				else [lessons_reference_dir_path] if suffix == "workbook"
				else []
			)).any(func(path_start: String) -> bool: return path.begins_with(path_start))
			or exclude_patterns.any(func(pattern: String) -> bool: return (path.match(pattern)))
		)
	var source_file_paths: Array = Utils.fs_find().result.filter(should_be_copied_predicate)

	# Copying files and replacing paths.
	for source_file_path: String in source_file_paths:
		source_file_path = ProjectSettings.globalize_path(source_file_path)
		var destination_file_path := source_file_path.replace(
			source_project_dir_path, destination_project_dir_path
		)
		if suffix == "workbook" and source_file_path.begins_with(source_solutions_dir_path):
			destination_file_path = source_file_path.replace(source_project_dir_path, destination_plugin_dir_path)
		DirAccess.make_dir_recursive_absolute(destination_file_path.get_base_dir())
		DirAccess.copy_absolute(source_file_path, destination_file_path)

		var extension := source_file_path.get_extension()
		var do_replace := (suffix == "workbook" and extension in REPLACE_EXTS)
		if do_replace:
			var contents := FileAccess.get_file_as_string(destination_file_path)
			contents = contents.replace(Paths.SOLUTIONS_PATH, solution_dir_path)
			FileAccess.open(destination_file_path, FileAccess.WRITE).store_string(contents)

	# Clean up the project.godot file. Remove enabled plugins and autoloads and update the project name.
	var project_file_path := destination_project_dir_path.path_join(PROJECT_FILE)
	var cfg = ConfigFile.new()
	cfg.load(project_file_path)
	cfg.set_value(APP_SECTION, APP_NAME_KEY, "%s (%s)" % [ProjectSettings.get_setting(APP_SECTION.path_join(APP_NAME_KEY)), suffix.capitalize()])
	for section in [PLUGINS_SECTION, AUTOLOAD_SECTION]:
		if cfg.has_section(section):
			cfg.erase_section(section)
	cfg.save(project_file_path)

	# If generating the workbook project, ensure lessons directory is present and generate practice files from solutions.
	if suffix == "workbook":
		var to_destination_map := func(p: String) -> String:
			return destination_project_dir_path.path_join(p.replace(Paths.RES, ""))
		var to_remove_dir_paths :=  [Paths.SOLUTIONS_PATH, Paths.PRACTICES_PATH].map(to_destination_map)
		for to_remove_dir_path: String in to_remove_dir_paths:
			Utils.fs_remove_dir(to_remove_dir_path)

		if not DirAccess.dir_exists_absolute(destination_project_dir_path.path_join("lessons")):
			DirAccess.make_dir_recursive_absolute(destination_project_dir_path.path_join("lessons"))

		var output := []
		var commands_list := [
			# We first need to open the destination project once to import it and ensure that the cache is built. Otherwise, we will not be able to process practices.
			["--path", destination_project_dir_path, "--headless", "--editor", "--quit"],
			# Then we generate the practice files and modify the project.
			["--path", destination_project_dir_path, "--headless", "--script", plugin_dir_path.path_join("build.gd"), "--", "--generate-practices", "--do-disable-plugins", "--do-project-diff"]
		]
		print("Generating practice files from solutions in workbook project...")
		for arguments: Array in commands_list:
			prints("Running:", GODOT_EXE, " ".join(arguments))
			return_code = Utils.os_execute(GODOT_EXE, arguments)
			if return_code == ReturnCode.EXE_NOT_FOUND:
				push_error("FAIL: Godot 4 executable expected at '%s' but not found." % GODOT_EXE)

			elif output.any(func(s: String) -> bool: return 'FAIL' in s):
				return_code = ReturnCode.FAIL
				Utils.fs_remove_dir(destination_project_dir_path)

			if return_code != ReturnCode.OK:
				break
	# For the solutions project, remove the main scene from the project file. We want the user to land on an empty project.
	elif suffix == "solutions":
		var solutions_project_file_path := destination_project_dir_path.path_join(PROJECT_FILE)
		var solutions_cfg := ConfigFile.new()
		solutions_cfg.load(solutions_project_file_path)
		if solutions_cfg.has_section_key(APP_SECTION, RUN_MAIN_SCENE_KEY):
			solutions_cfg.erase_section_key(APP_SECTION, RUN_MAIN_SCENE_KEY)
		solutions_cfg.save(solutions_project_file_path)

	return return_code


func build_practices(do_disable_plugins := false, do_project_diff := false) -> ReturnCode:
	var result := ReturnCode.OK
	if do_disable_plugins:
		var cfg = ConfigFile.new()
		cfg.load(PROJECT_FILE)
		for section in [PLUGINS_SECTION, AUTOLOAD_SECTION]:
			if cfg.has_section(section):
				cfg.erase_section(section)
		cfg.save(PROJECT_FILE)

	for dir_name in DirAccess.get_directories_at(Paths.SOLUTIONS_PATH):
		result = build_practice(dir_name)
		if result == ReturnCode.FAIL:
			break

	var project_diff_path := Paths.SOLUTIONS_PATH.path_join("diff.gd")
	if FileAccess.file_exists(project_diff_path):
		const PROJECT_FUNC_NAME := "edit_project_configuration"
		var project_diff := load(project_diff_path)
		if do_project_diff and project_diff != null and PROJECT_FUNC_NAME in project_diff:
			project_diff.call(PROJECT_FUNC_NAME)
	return result


func build_practice(dir_name: StringName, is_forced := false) -> ReturnCode:
	print_rich("Building [b]%s[/b]..." % dir_name)
	var solution_dir_path := Paths.SOLUTIONS_PATH.path_join(dir_name)
	var solution_file_paths := Utils.fs_find("*", solution_dir_path).result

	var predicate := func(x: String) -> bool:
		return not (x.ends_with("/test.gd") or x.ends_with("/diff.gd"))
	solution_file_paths.assign(solution_file_paths.filter(predicate))

	if solution_file_paths.is_empty():
		print_rich(LOG_MESSAGE % ["Nothing to do", "[color=orange]SKIP[/color]"])

	var solution_diff_path := solution_dir_path.path_join("diff.gd")
	var solution_diff: GDScript = null
	if FileAccess.file_exists(solution_diff_path):
		solution_diff = load(solution_diff_path)

	for solution_file_path: String in solution_file_paths:
		var extension := solution_file_path.get_extension()
		var practice_file_path: String = solution_file_path.replace(
			Paths.SOLUTIONS_PATH, Paths.PRACTICES_PATH
		)
		var practice_file_modified_time := FileAccess.get_modified_time(practice_file_path)
		if (
			(
				FileAccess.file_exists(practice_file_path)
				and practice_file_modified_time > FileAccess.get_modified_time(solution_file_path)
				and practice_file_modified_time > FileAccess.get_modified_time(solution_diff_path)
			)
			and not is_forced
		):
			print_rich(LOG_MESSAGE % [practice_file_path, "[color=orange]SKIP[/color]"])
			continue

		DirAccess.make_dir_recursive_absolute(practice_file_path.get_base_dir())
		var was_copied := false
		if extension == "tscn":
			var solution_scene: Node = load(solution_file_path).instantiate()
			if solution_diff != null:
				var diff_func_names := solution_diff.get_script_method_list().map(func(d: Dictionary) -> String: return d.name)
				var diff_func_name := solution_file_path.get_file().get_basename()
				if diff_func_name in diff_func_names:
					solution_diff.call(diff_func_name, solution_scene)
					print_rich(LOG_MESSAGE % [solution_file_path, "[color=blue]DIFF[/color]"])
				else:
					print_rich(LOG_MESSAGE % ["%s:%s() not found" % [solution_diff_path, diff_func_name], "[color=orange]SKIP[/color]"])

			var practice_packed_scene := PackedScene.new()
			practice_packed_scene.pack(solution_scene)
			ResourceSaver.save(practice_packed_scene, practice_file_path)
			was_copied = true

		if not was_copied:
			DirAccess.copy_absolute(solution_file_path, practice_file_path)
			print_rich(LOG_MESSAGE % [practice_file_path, "[color=green]COPY[/color]"])

		if extension in REPLACE_EXTS:
			var contents := FileAccess.get_file_as_string(practice_file_path)
			if extension == "gd":
				contents = _process_gd(contents)
			elif extension == "tscn":
				contents = regex_uid.sub(contents, "", true)
			contents = Paths.to_practice(contents)
			FileAccess.open(practice_file_path, FileAccess.WRITE).store_string(contents)
			print_rich(LOG_MESSAGE % [practice_file_path, "[color=yellow]PROCESS[/color]"])
	return ReturnCode.OK


func _process_gd(contents: String) -> String:
	var partial_result := []
	for line in contents.split("\n"):
		var processed := _process_line(line)
		if processed.do_skip:
			continue
		partial_result.push_back(processed.line)
	return "\n".join(partial_result).strip_edges() + "\n"


func _process_line(line: String) -> Dictionary:
	var result := {line = line, do_skip = false}
	var regex_line_match := regex_line.search(line)
	if regex_line_match != null and not regex_line_match.strings[2].is_empty():
		result.line = _process_tabs(
			regex_line_match.strings[1], regex_line_match.strings[3].strip_edges()
		)
		result.do_skip = not line.strip_edges().is_empty() and result.line.strip_edges().is_empty()
	return result


func _process_tabs(prefix: String, line: String) -> String:
	var tabs := prefix.count("\t")
	var regex_shift_match := regex_shift.search(line)
	if regex_shift_match != null:
		for shift in regex_shift_match.strings[1]:
			tabs += DENTS[shift]
		line = regex_shift_match.strings[2]
	return "\t".repeat(tabs) + line
