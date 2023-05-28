extends CharacterBody2D

var speed = randf_range(200, 300)

var health = 3

@onready var player := get_node("/root/Game/Player")


func _ready():
	print([false, true, true].reduce(func(accum, number): return accum + int(number), 0))

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
