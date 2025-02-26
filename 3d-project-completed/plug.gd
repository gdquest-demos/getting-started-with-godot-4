#!/usr/bin/env -S godot --headless --script
extends "res://addons/gd-plug/plug.gd"


func _plugging() -> void:
	plug(
		"git@github.com:GDQuest/GDPractice.git",
		{
			include =
			[
				"addons/gdpractice",
				"addons/gdquest_theme_utils",
				"addons/gdquest_sparkly_bag"
			]
		}
	)
