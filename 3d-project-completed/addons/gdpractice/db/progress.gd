extends Resource

## Path to the first version of the progress file.
const PATH_V1 := "user://progress.tres"
## Current path used to save the progress file, for the latest version.
const PATH := "user://progress_v2.tres"


@export var state := {}

func _init() -> void:
	resource_path = PATH
