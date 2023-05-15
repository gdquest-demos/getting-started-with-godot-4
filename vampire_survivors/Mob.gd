extends CharacterBody2D

var speed = randf_range(200, 300)

var health = 3

@onready var player := get_node("/root/Game/Player")


func _physics_process(delta):
	if not is_instance_valid(player):
		return

	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()


func take_damage():
	health -= 1
	if health == 0:
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
