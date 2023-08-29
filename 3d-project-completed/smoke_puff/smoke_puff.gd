extends Node3D

@onready var animation_player = %AnimationPlayer
@onready var sound = %Sound


func _ready():
	sound.pitch_scale = randfn(1.0, 0.1)
	sound.play()
	animation_player.play("poof")
	await animation_player.animation_finished
	queue_free()
