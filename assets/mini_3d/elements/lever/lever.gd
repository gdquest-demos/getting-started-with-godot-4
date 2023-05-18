extends Switch3D

@export var off_color : Color 
@export var on_color : Color 

@onready var lever_handle = %LeverHandle
@onready var area_3d = %Area3D
@onready var sound = %Sound

func _ready():
	connect("state_changed", check_state)
	area_3d.connect("input_event", func(_camera, event, _pos, _normal, _shape_idx):
		if !(event is InputEventMouseButton): return
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			state = !state
		)
func check_state(_s : bool):
	var color = on_color if state else off_color
	var angle = -60.0 if state else 60.0
	var t = create_tween().set_parallel(true)
	t.tween_property(lever_handle, "rotation_degrees:z", angle, 0.2)
	t.tween_property(lever_handle.get_surface_override_material(1), "albedo_color", color, 0.2)
	sound.pitch_scale = randfn(1.0, 0.1)
	sound.play()
