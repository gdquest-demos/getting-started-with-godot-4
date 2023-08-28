extends CharacterBody2D

var speed = randf_range(200, 300)

var health = 3

@onready var player = get_node("/root/Game/Player")
@onready var slime = %Slime

signal KO

func _ready():
	slime.play_walk()

func _physics_process(delta):
	if not is_instance_valid(player):
		return

	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()


func take_damage():
	slime.play_hurt()
	health -= 1
	if health == 0:
		emit_signal("KO")
		queue_free()
