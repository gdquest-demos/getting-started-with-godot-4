extends Connector

@onready var bulb = %Bulb
@onready var sound = %Sound

@export var delay = 0.0

var tween : Tween = null

var transparent = Color(1.0, 1.0, 1.0, 0.2)
var light_black = Color(0.2, 0.2, 0.2, 1.0)

func on_state_change():
	
	var energy = 1.2 if state else 0.0
	var albedo_color = light_black if state else transparent
	
	if tween && tween.is_valid(): tween.kill()
	tween = create_tween()
	
	if !state:
		tween.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	tween.set_parallel(true)
	tween.tween_property(bulb.material_override, "emission_energy_multiplier", energy, 0.5).set_delay(delay)
	tween.tween_property(bulb.material_override, "albedo_color", albedo_color, 0.5).set_delay(delay)
	
	tween.tween_callback(func():
		sound.pitch_scale = randfn(1.0, 0.1)
		sound.play()
		).set_delay(delay)
