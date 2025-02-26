extends RigidBody3D

signal died

var speed = randf_range(2.0, 4.0)
var health = 3

@onready var bat_model = %bat_model
@onready var timer = %Timer

@onready var player = get_node("/root/Game/Player")

@onready var hurt_sound = %HurtSound
@onready var ko_sound = %KOSound


func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	direction.y = 0.0
	linear_velocity = direction * speed
	bat_model.rotation.y = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI


func take_damage():
	if health <= 0:
		return

	bat_model.hurt()
	health -= 1
	hurt_sound.pitch_scale = randfn(1.0, 0.1)
	hurt_sound.play()

	if health == 0:
		ko_sound.play()

		set_physics_process(false)
		gravity_scale = 1.0
		var direction = player.global_position.direction_to(global_position)
		var random_upward_force = Vector3.UP * randf() * 5.0
		apply_central_impulse(direction.rotated(Vector3.UP, randf_range(-0.2, 0.2)) * 10.0 + random_upward_force)

		timer.start()


func _on_timer_timeout():
	queue_free()
	died.emit()
