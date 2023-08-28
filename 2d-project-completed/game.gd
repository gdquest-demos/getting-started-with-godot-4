extends Node


func spawn_mob():
	%PathFollow2D.progress_ratio = randf()
	var new_mob = preload("res://mob.tscn").instantiate()
	new_mob.connect("KO", func():
			make_smoke(new_mob.global_position)
			)
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)


func _on_timer_timeout():
	spawn_mob()


func make_smoke(position : Vector2):
	var smoke_scene = preload("res://smoke_explosion/smoke_explosion.tscn")
	var smoke = smoke_scene.instantiate()
	smoke.z_index = 10
	add_child(smoke)
	smoke.global_position = position


func _on_player_health_depleted():
	%GameOver.show()
	get_tree().paused = true
