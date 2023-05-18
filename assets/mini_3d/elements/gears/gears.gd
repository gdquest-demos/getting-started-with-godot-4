extends Connector

@onready var big_gear = %BigGear
@onready var small_gear = %SmallGear
@onready var sound = %Sound

var tween : Tween = null

var base_rotation = 0.0


func on_state_change():
	if tween && tween.is_valid(): tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	
	var sound_db = 0.0 if state else -80.0
	var sound_t = create_tween()
	sound_t.tween_property(sound, "volume_db", sound_db, 0.5)
	
	if state:
		tween.set_loops(0)
		tween.tween_method(rotate_gear, base_rotation, base_rotation + 360.0, 2.0)
		sound.play()
	else:
		tween.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_method(rotate_gear, base_rotation, base_rotation + 25.0, 0.5)
		
		sound_t.tween_callback(sound.stop)
	
func rotate_gear(progress):
	base_rotation = progress
	big_gear.rotation_degrees.y = progress
	small_gear.rotation_degrees.y = -progress
	
