extends Connector

var start_position : Vector3
var end_position : Vector3
var tween : Tween = null

@export var end : Marker3D
@export var on_color : Color
@export var off_color : Color
@onready var body = %Body

func _ready():
	super()
	start_position = global_position
	end_position = end.global_position

func on_state_change():
	if tween && tween.is_valid(): tween.kill()
	
	tween = create_tween()
	
	if state:
		tween.set_loops(0)
		tween.tween_property(self, "position", end_position, 1.0).set_delay(1.0)
		tween.tween_property(self, "position", start_position, 1.0).set_delay(1.0)
	else:
		tween.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position", start_position, 1.0)
	
	var color = on_color if state else off_color
	
	var t = create_tween().set_parallel(true)
	t.tween_property(body.material_override, "albedo_color", color, 0.2)
