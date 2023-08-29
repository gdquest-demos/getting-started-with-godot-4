extends Node2D

@onready var sprite = %Sprite


func _ready():
	var t = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(sprite, "position:x", 16.0, 0.25)
	t.tween_property(sprite, "scale", Vector2.ONE * 1.25, 0.25)
	t.tween_property(sprite, "modulate:a", 0.0, 0.25).set_delay(0.1)
	t.chain().tween_callback(queue_free)
