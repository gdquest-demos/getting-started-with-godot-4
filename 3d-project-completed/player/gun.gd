extends Node3D

func shoot():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation_degrees:x", -16.0, 0.05)
	tween.tween_property(self, "rotation_degrees:x", 0.0, 0.3)
