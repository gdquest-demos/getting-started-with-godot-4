extends Node3D

signal mob_spawned(mob)

@export var mob_to_spawn: PackedScene = preload("res://mob.tscn")


func _on_timer_timeout():
	var new_mob = mob_to_spawn.instantiate()
	add_child(new_mob)
	mob_spawned.emit(new_mob)
