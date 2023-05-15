extends Area2D

@export var speed = 1000


func _physics_process(delta):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta


func _on_body_entered(body):
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage()
