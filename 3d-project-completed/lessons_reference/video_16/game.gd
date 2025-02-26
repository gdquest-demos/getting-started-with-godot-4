extends Node3D

var player_score = 0

@onready var label := %Label


func increase_score():
	player_score += 1
	label.text = "Score: " + str(player_score)


func _on_kill_plane_body_entered(body):
	get_tree().reload_current_scene.call_deferred()


func _on_mob_spawner_3d_mob_spawned(mob):
	mob.died.connect(func():
		increase_score()
		do_poof(mob.global_position)
	)
	do_poof(mob.global_position)


func do_poof(mob_position):
	const SMOKE_PUFF = preload("res://mob/smoke_puff/smoke_puff.tscn")
	var poof := SMOKE_PUFF.instantiate()
	add_child(poof)
	poof.global_position = mob_position
