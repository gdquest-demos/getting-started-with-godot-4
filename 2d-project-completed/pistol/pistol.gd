extends Node2D

@onready var pistol = %Pistol


func shoot():
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(pistol, "rotation_degrees", -25.0, 0.15).set_trans(Tween.TRANS_BACK)
	tween.tween_property(pistol, "rotation_degrees", 0.0, 0.8).set_trans(Tween.TRANS_ELASTIC)
