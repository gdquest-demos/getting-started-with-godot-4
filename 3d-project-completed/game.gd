extends Node3D

var player_score = 0

var poof_vfx = preload("res://smoke_puff/smoke_puff.tscn")

func increase_score():
	player_score += 1
	%ScoreLabel.text = "Score: " + str(player_score)


func _on_kill_plane_body_entered(body):
	get_tree().reload_current_scene()


func _on_mob_spawner_3d_mob_spawned(mob):
	do_poof(mob.global_position)
	mob.died.connect(func():
		do_poof(mob.global_position)
		)
	mob.died.connect(increase_score)

func do_poof(mob_position : Vector3):
	var poof = poof_vfx.instantiate()
	poof.scale = Vector3.ONE * 0.5
	add_child(poof)
	poof.global_position = mob_position
