extends RigidBody3D

var speed = randf_range(2, 4)

var health = 3

@onready var player := get_node("/root/Game/Player")


func _physics_process(delta):
	if not is_instance_valid(player):
		return

	var direction = global_position.direction_to(player.global_position)
	direction.y = 0.0
	linear_velocity = direction * speed


func take_damage():
	health -= 1
	if health == 0:
		set_physics_process(false)
		gravity_scale = 1.0
		var direction_back = -transform.basis.z * 20.0
		var direction_random = Vector3(randf(), randf(), randf()).normalized()
		apply_central_impulse(direction_back + direction_random * randf_range(0.0, 2.0))
