extends RigidBody3D

var speed = randf_range(2, 4)
var health = 3

@onready var player = get_node("/root/Game/Player")


func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	direction.y = 0.0
	linear_velocity = direction * speed


func take_damage():
	health -= 1
	if health == 0:
		set_physics_process(false)
		gravity_scale = 1.0
		var direction_back = player.global_position.direction_to(global_position)
		var random_upward_force = Vector3.UP * randf() * 5.0
		apply_central_impulse(direction_back.rotated(Vector3.UP, randf_range(-0.2, 0.2)) * 10.0 + random_upward_force)
