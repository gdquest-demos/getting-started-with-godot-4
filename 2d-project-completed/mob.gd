extends CharacterBody2D

signal died


var speed = randf_range(200, 300)

var health = 3

@onready var player = get_node("/root/Game/Player")
@onready var slime = %Slime


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
		var smoke_scene = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = smoke_scene.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position
		queue_free()
