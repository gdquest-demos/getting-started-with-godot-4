## Utility script to handle paths and file names for practice and solution files.
const Utils := preload("../gdquest_sparkly_bag/sparkly_bag_utils.gd")

const RES := "res://"
const PRACTICES_PATH := "res://practices"
const SOLUTIONS_PATH := "res://practice_solutions"


static func to_solution(path: String) -> String:
	return path.replace(PRACTICES_PATH, SOLUTIONS_PATH)


static func to_practice(path: String) -> String:
	return path.replace(SOLUTIONS_PATH, PRACTICES_PATH)


static func get_dir_name(path: String, relative_to := SOLUTIONS_PATH) -> String:
	var result := path.replace(relative_to, "")
	result = "" if result == path else result.lstrip(Utils.SEP).get_slice(Utils.SEP, 0)
	return result
