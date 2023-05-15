extends Area3D

@export var speed = 10


func _physics_process(delta):
	position += transform.basis.z * speed * delta


func _on_body_entered(body):
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage()
