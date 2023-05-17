extends Node2D

var range = 400.0
var speed = 600.0
var timer : SceneTreeTimer
@onready var sprite = %Sprite

signal impact(impact_position)

func _ready():
	timer = get_tree().create_timer(range / speed)
	timer.connect("timeout", func():
		impact.emit(global_position)
		queue_free()
		)
	
	var t = create_tween().set_loops(0)
	t.tween_property(sprite, "scale", Vector2.ONE * 1.2, 0.1)
	t.tween_property(sprite, "scale", Vector2.ONE * 0.8, 0.1)
	
		
func _process(delta):
	var v = Vector2.from_angle(rotation) * speed * delta
	position += v
