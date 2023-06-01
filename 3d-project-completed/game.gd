extends Node3D

var player_score = 0

func increase_score():
	player_score += 1
	%ScoreLabel.text = "Score: " + str(player_score)


func _on_kill_plane_body_entered(body):
	get_tree().reload_current_scene()


func _on_mob_spawner_3d_mob_spawned(mob):
	mob.died.connect(increase_score)


