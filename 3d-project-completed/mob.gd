extends RigidBody3D

signal died

var speed = randf_range(2, 4)
var health = 3

@onready var player = get_node("/root/Game/Player")
@onready var bat_skin = %BatSkin

@onready var hurt_sound = %HurtSound
@onready var ko_sound = %KOSound

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	direction.y = 0.0
	linear_velocity = direction * speed
	bat_skin.rotation.y = -Vector2(direction.x, direction.z).angle() - PI / 2.0

func take_damage():
	if health <= 0:
		return
	bat_skin.hurt()
	hurt_sound.pitch_scale = randfn(1.0, 0.1)
	hurt_sound.play()
	health -= 1
	if health == 0:
		ko_sound.pitch_scale = randfn(1.0, 0.1)
		ko_sound.play()
		set_physics_process(false)
		gravity_scale = 1.0
		var direction_back = player.global_position.direction_to(global_position)
		var random_upward_force = Vector3.UP * randf() * 5.0
		apply_central_impulse(direction_back.rotated(Vector3.UP, randf_range(-0.2, 0.2)) * 10.0 + random_upward_force)
		%DeathTimer.start()
	
func _on_death_timer_timeout():
	died.emit()
	queue_free()
