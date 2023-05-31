extends Node3D


func _on_area_3d_body_entered(body):
	%AnimationPlayer.play("press")


func _on_area_3d_body_exited(body):
	%AnimationPlayer.play("release")
