extends PanelContainer

@onready var animation_player: AnimationPlayer = %AnimationPlayer


func off() -> void:
	animation_player.play("off")


func note() -> void:
	animation_player.play("note")


func safe() -> void:
	animation_player.play("safe")


func warn() -> void:
	animation_player.play("warn")
