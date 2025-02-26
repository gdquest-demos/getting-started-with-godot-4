# GDQuest Theme Utils

Is a collection of utilities dealing with themes for developing consistent plugin UIs.

## ✓ Install

### Manual

1. Copy the contents of this folder into `res://addons/gdquest_sparkly_bag/`.
1. Profit.

### gd-plug

1. Install **gd-plug** using the Godot Asset Library.
1. Save the following code into the file `res://plug.gd` (create the file if necessary):

  ```gdscript
  #!/usr/bin/env -S godot --headless --script
  extends "res://addons/gd-plug/plug.gd"


  func _plugging() -> void:
  	plug(
  		"git@github.com:GDQuest/godot-addons.git",
  		{include = ["addons/gdquest_theme_utils"]}
  	)
  ```

1. On Linux, make the `res://plug.gd` script executable with `chmod +x plug.gd`.
1. Using the command line, run `./plug.gd install` or `godot --headless --script plug.gd install`.

## Notes

These functions are extracted from theme utils in [Godot Tours](https://github.com/GDQuest/godot-tours/).
