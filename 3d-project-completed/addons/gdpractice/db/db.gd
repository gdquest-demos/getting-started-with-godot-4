## Keeps track of the student's progress. Most importantly which practices have been completed.
const Progress := preload("progress.gd")
const Paths := preload("../paths.gd")
const Metadata := preload(Paths.SOLUTIONS_PATH + "/metadata.gd")

const PracticeMetadata := Metadata.PracticeMetadata

var progress: Progress = null


func _init(metadata: Metadata) -> void:
	if ResourceLoader.exists(Progress.PATH):
		progress = ResourceLoader.load(Progress.PATH)
	elif ResourceLoader.exists(Progress.PATH_V1):
		progress = _update_save_file_format()
		save()
	else:
		progress = Progress.new()
		for practice_metadata: PracticeMetadata in metadata.list:
			progress.state[practice_metadata.id] = {completion = 0, tries = 0}
		save()


func save() -> void:
	ResourceSaver.save(progress, Progress.PATH)


func update(dict: Dictionary) -> void:
	for id in dict:
		for key in dict[id]:
			if (
				key == "completion"
				and progress.state.has(id)
				and progress.state[id].completion == 1
			):
				continue
			if not progress.state.has(id):
				progress.state[id] = {}
			progress.state[id][key] = dict[id][key]
	progress.emit_changed()


## Updates the save file format if it's outdated and returns the updated progress resource.
static func _update_save_file_format() -> Progress:
	# We renamed the addon folder at some point for Windows users, this requires migrating the original save data.
	# We need to first replace the path to the loader resource in the save file to load it, then save it back.
	if ResourceLoader.exists(Progress.PATH_V1):
		print("Migrating progress save file from version 1 to the new resource file format...")
		# Open the file as text and replace V1_RESOURCE_CLASS_PATH with Progress.resource_path
		const V1_RESOURCE_CLASS_PATH := "res://addons/gdquest_practice_framework/db/progress.gd"
		var file := FileAccess.open(Progress.PATH_V1, FileAccess.READ_WRITE)
		var content := file.get_as_text().replace(V1_RESOURCE_CLASS_PATH, Progress.resource_path)
		file.store_string(content)
		file.close()
		var progress_v1 := ResourceLoader.load(Progress.PATH_V1).duplicate(true)
		if progress_v1 == null:
			printerr("Failed to load the progress save file from version 1.")
		else:
			print("Success! The progress save file has been migrated to the new resource file format.")
		return progress_v1

	return null
