extends Node3D

signal mob_spawned(mob)

@export var mob_to_spawn: PackedScene = null
@export var cooldown_time := 4.0


func _ready():
	%Timer.wait_time = cooldown_time


func _on_timer_timeout():
	var new_mob = mob_to_spawn.instantiate()
	add_child(new_mob)
	new_mob.global_position = %Marker3D.global_position
	mob_spawned.emit(new_mob)
	
	# Each time a mob spawns, we make the game a little harder
	const MINIMUM_SPAWN_TIME = 1.5
	%Timer.wait_time = max(MINIMUM_SPAWN_TIME, %Timer.wait_time - 0.1)
