extends CharacterBody2D

signal health_depleted

var health = 100.0

@onready var hurt_box = $HurtBox
@onready var health_bar = $HealthBar


func _physics_process(delta):
	const SPEED = 600.0
	var direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	velocity = direction * SPEED

	move_and_slide()
	
	# Taking damage
	const DAMAGE_RATE = 20.0
	var overlapping_mobs = hurt_box.get_overlapping_bodies()
	if overlapping_mobs:
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		health_bar.value = health
		if health <= 0.0:
			# consider using queue_free and listening to tree_exited
			# unless you mean to have an animation / juice
			health_depleted.emit()
