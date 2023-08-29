extends CharacterBody2D


func _physics_process(delta):
	const SPEED = 600.0
	const ACCELERATION = 3000.0
	var direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION * delta)
	
	move_and_slide()
