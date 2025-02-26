const Paths := preload("../paths.gd")
const Utils := preload("../../gdquest_sparkly_bag/sparkly_bag_utils.gd")

static var _name_sorter := func(x: Dictionary, y: Dictionary) -> bool: return x.name < y.name

static var _erase_arg_name_transformer := func(f: Dictionary) -> Dictionary:
	f.args.map(func(arg: Dictionary) -> Dictionary:
		arg.erase("name")
		return arg)
	return f

static var _list := {}
static var _practice_base_path := ""


static func setup(practice_base_path: String) -> void:
	_practice_base_path = practice_base_path

	var path_transformer := func(x: String) -> Dictionary:
		return {practice = x, solution = Paths.to_solution(x)}

	var file_exists_predicate := func(x: Dictionary) -> bool:
		return FileAccess.file_exists(x.solution)

	var load_transformer := func(x: Dictionary) -> Dictionary:
		return {practice = load(x.practice), solution = load(x.solution)}

	var patterns := {scripts = "*.gd", scenes = "*.tscn"}
	for key in patterns:
		_list[key] = (
			Utils.fs_find(patterns[key], practice_base_path).result
			.map(path_transformer)
			.filter(file_exists_predicate)
			.map(load_transformer)
		)


static func check() -> bool:
	if _list.scripts.is_empty():
		var message := "Nothing to do"
		return true
	# TODO: consider selectively skipping checks based on the type of requirement. Some practices need different functions and node structures.
	# return _check_constants() and _check_properties() and _check_methods() and _check_signals() and _check_nodes()
	return true


static func _check_methods() -> bool:
	return _list.scripts.all(func(script: Dictionary) -> bool:
		var practice_method_list: Array[Dictionary] = script.practice.get_script_method_list()
		var solution_method_list: Array[Dictionary] = script.solution.get_script_method_list()
		practice_method_list.sort_custom(_name_sorter)
		solution_method_list.sort_custom(_name_sorter)

		var result := practice_method_list.map(_erase_arg_name_transformer) == solution_method_list.map(_erase_arg_name_transformer)
		return result
	)


static func _check_properties() -> bool:
	return _list.scripts.all(func(script: Dictionary) -> bool:
		var script_file_name: String = script.practice.resource_path.get_file()
		var predicate := func(prop: Dictionary) -> bool: return prop.name != script_file_name and prop.name != "metadata"
		var practice_property_list: Array[Dictionary] = script.practice.get_script_property_list().filter(predicate)
		var solution_property_list: Array[Dictionary] = script.solution.get_script_property_list().filter(predicate)
		practice_property_list.sort_custom(_name_sorter)
		solution_property_list.sort_custom(_name_sorter)

		var result := practice_property_list == solution_property_list
		return result
	)


static func _check_signals() -> bool:
	return _list.scripts.all(func(script: Dictionary) -> bool:
		var practice_signal_list: Array[Dictionary] = script.practice.get_script_signal_list()
		var solution_signal_list: Array[Dictionary] = script.solution.get_script_signal_list()
		practice_signal_list.sort_custom(_name_sorter)
		solution_signal_list.sort_custom(_name_sorter)

		var result := practice_signal_list.map(_erase_arg_name_transformer) == solution_signal_list.map(_erase_arg_name_transformer)
		return result
	)


static func _check_constants() -> bool:
	return _list.scripts.all(func(script: Dictionary) -> bool:
		var practice_constant_map: Dictionary = script.practice.get_script_constant_map()
		var solution_constant_map: Dictionary = script.solution.get_script_constant_map()

		var result := practice_constant_map == solution_constant_map
		return result
	)


static func _check_nodes() -> bool:
	return _list.scenes.all(func(scene: Dictionary) -> bool:
		var practice_scene_tree_proxy := _get_scene_tree_proxy(scene.practice.get_state())
		var solution_scene_tree_proxy := _get_scene_tree_proxy(scene.solution.get_state())
		var result := practice_scene_tree_proxy.keys() == solution_scene_tree_proxy.keys()
		if result:
			for key in practice_scene_tree_proxy:
				var practice_items: Array = practice_scene_tree_proxy[key]
				var solution_items: Array = solution_scene_tree_proxy[key]
				result = (
					result
					and practice_items.size() == solution_items.size()
					and _check_scene_tree_proxy_items(practice_items, solution_items)
				)
				if not result:
					break
		return result
	)


static func _check_scene_tree_proxy_items(practice_items: Array, solution_items: Array) -> bool:
	var result := true
	for idx in range(practice_items.size()):
		var practice_item: Dictionary = practice_items[idx]
		var solution_item: Dictionary = solution_items[idx]
		var practice_script_path: String = practice_item.get("script_path", Paths.PRACTICES_PATH)
		var solution_script_path: String = solution_item.get("script_path", Paths.SOLUTIONS_PATH)
		result = result and (
			practice_item.type == solution_item.type
			and practice_script_path.begins_with(Paths.PRACTICES_PATH)
			and solution_script_path.begins_with(Paths.SOLUTIONS_PATH)
			and practice_script_path.trim_prefix(Paths.PRACTICES_PATH) == solution_script_path.trim_prefix(Paths.SOLUTIONS_PATH)
		)
		if not result:
			break
	return result


# TODO: the proxy dictionary uses node paths as keys which might be too strict because it relies
# on node names. Need a better solution to test for node types instead.
static func _get_scene_tree_proxy(state: SceneState) -> Dictionary:
	var result := {}
	for idx in range(state.get_node_count()):
		var path_for_parent := state.get_node_path(idx, true)
		if not path_for_parent in result:
			result[path_for_parent] = []

		var item := {type = state.get_node_type(idx)}
		for prop_idx in range(state.get_node_property_count(idx)):
			if state.get_node_property_name(idx, prop_idx) == "script":
				var script: Script = state.get_node_property_value(idx, prop_idx)
				item.script_path = script.resource_path
				break
		result[path_for_parent].append(item)

	for key in result:
		result[key].sort_custom(func(x: Dictionary, y: Dictionary) -> bool: return x.type < y.type)
	return result
