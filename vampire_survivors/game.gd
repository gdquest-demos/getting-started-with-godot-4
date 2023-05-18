extends Node

@onready var path_follow_2d = %PathFollow2D
@onready var label = %Label
@onready var game_over = %GameOver


func spawn_mob():
	path_follow_2d.progress_ratio = randf()
	var new_mob = preload("res://vampire_survivors/mob.tscn").instantiate()
	new_mob.global_position = path_follow_2d.global_position
	add_child(new_mob)


func _on_timer_timeout():
	spawn_mob()


func _on_player_health_depleted():
	game_over.show()
	get_tree().paused = true
