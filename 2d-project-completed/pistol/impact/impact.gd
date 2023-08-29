extends Node2D

@onready var sprite = %Sprite


func _ready():
	var t = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT)
	t.tween_property(sprite, "scale", Vector2.ONE * 1.35, 0.3).from(Vector2.ONE * 0.6)
	t.tween_property(sprite, "modulate:a", 0.0, 0.15).set_delay(0.15)
	t.chain().tween_callback(queue_free)
