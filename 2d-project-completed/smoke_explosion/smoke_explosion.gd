extends Node2D

@onready var animation_player = %AnimationPlayer
@onready var smoke = %Smoke


func _ready():
	smoke.material.set_shader_parameter("texture_offset", Vector2(randfn(0.0, 1.0), randfn(0.0, 1.0)))
	animation_player.play("explosion")
	await animation_player.animation_finished
	queue_free()
