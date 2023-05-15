extends Area2D

@onready var timer = $Timer
@onready var shooting_point = $WeaponPivot/ShootingPoint

func _process(delta):
	var enemies_in_range = get_overlapping_bodies()
	if enemies_in_range:
		var target_enemy = enemies_in_range.front()
		look_at(target_enemy.global_position)
		if timer.is_stopped():
			shoot_at(target_enemy)

func shoot_at(target):
	timer.start()

	const BULLET = preload("res://vampire_survivors/bullet_2d.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_transform = shooting_point.global_transform
	shooting_point.add_child(new_bullet)
