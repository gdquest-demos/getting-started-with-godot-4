extends Node3D

@onready var anchor = %Anchor

func shoot():
	var t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(anchor, "rotation_degrees:x", -16.0, 0.05)
	t.tween_property(anchor, "rotation_degrees:x", 0.0, 0.3)
