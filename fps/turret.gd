extends StaticBody3D

@onready var timer = %Timer
@onready var marker_3d = %Marker3D


func _on_area_3d_body_entered(body):
	shoot()
	timer.start()


func _on_area_3d_body_exited(body):
	timer.stop()


func _on_timer_timeout():
	shoot()


func shoot():
	var new_bullet = preload("res://fps/bullet_3d.tscn").instantiate()
	add_child(new_bullet)
	new_bullet.global_transform = marker_3d.global_transform
