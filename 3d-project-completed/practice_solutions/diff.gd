static func edit_project_configuration() -> void:
	const INPUT_KEY := "input/%s"
	for action in InputMap.get_actions():
		if action.begins_with("ui") or action.begins_with("left_click"):
			continue
		ProjectSettings.set_setting(INPUT_KEY % action, null)
	ProjectSettings.set_setting("application/run/main_scene", "res://game.tscn")
	ProjectSettings.set_setting("display/window/size/viewport_width", null)
	ProjectSettings.set_setting("display/window/size/viewport_height", null)
	ProjectSettings.set_setting("display/window/stretch/mode", null)
	ProjectSettings.save()
