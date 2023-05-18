extends Connector

@onready var door_bottom = %DoorBottom
@onready var door_top = %DoorTop

@onready var sound = %Sound

func on_state_change():
	var top_value = 1.0 if state else 0.0
	var bottom_value = -1.0 if state else 0.0
	
	var t = create_tween().set_parallel(true)
	
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_BACK if state else Tween.TRANS_BOUNCE)
		
	t.tween_property(door_top, "position:y", top_value, 1.0)
	t.tween_property(door_bottom, "position:y", bottom_value, 1.0)
	sound.pitch_scale = randfn(1.0, 0.1)
	sound.play()
