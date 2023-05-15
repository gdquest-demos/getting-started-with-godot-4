extends Area2D

@onready var timer = %Timer
@onready var shooting_point = %ShootingPoint

func _process(delta):
	var enemies_in_range = get_overlapping_bodies()
	if enemies_in_range.size() > 0:
		var target_enemy = enemies_in_range.front()
		look_at(target_enemy.global_position)

func shoot():
	const BULLET = preload("res://vampire_survivors/bullet_2d.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_transform = shooting_point.global_transform
	shooting_point.add_child(new_bullet)


func _on_timer_timeout() -> void:
	shoot()
