extends Node2D

@onready var pistol = %Pistol
@onready var end = %End

func shoot():
	var t = create_tween().set_ease(Tween.EASE_OUT)
	t.tween_property(pistol, "rotation_degrees", -25.0, 0.15).set_trans(Tween.TRANS_BACK)
	t.tween_property(pistol, "rotation_degrees", 0.0, 0.8).set_trans(Tween.TRANS_ELASTIC)
