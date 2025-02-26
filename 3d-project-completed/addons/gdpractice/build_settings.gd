## Settings that can be modified on a per project basis to change how GDPractice operates at build time.
extends Node

## List of string patterns to skip from copying when building the workbook project. Any file in the project that matches any of these patterns will not be copied.
## You can use anything that String.match() supports. For example, "res://addons/*" to not copy any addon files.
## By default, GDPractice excludes the dot folders .git/, .godot/, and .plugged/
var workbook_exclude_patterns: Array[String] = []
## List of string patterns to skip from copying when building the workbook project. Any file in the project that matches any of these patterns will not be copied.
## You can use anything that String.match() supports. For example, "res://addons/*" to not copy any addon files.
## By default, GDPractice excludes the dot folders .git/, .godot/, and .plugged/
## For solution projects, it also excludes practice build and test scripts: test.gd and diff.gd files.
var solution_exclude_patterns: Array[String] = []
