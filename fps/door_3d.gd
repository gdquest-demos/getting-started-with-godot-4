extends Area3D


@onready var animation_player = $AnimationPlayer


func _on_body_entered(body):
	animation_player.play("open")

func _on_body_exited(body):
	animation_player.play("close")
