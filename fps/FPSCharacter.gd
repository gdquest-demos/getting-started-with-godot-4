extends CharacterBody3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5
		rotation_degrees.x = clamp(rotation_degrees.x - event.relative.y / 5, -80, 80)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta):
	const SPEED = 5.5
	const GRAVITY = 20
	const JUMP_VELOCITY = 10

	var input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = transform.basis * Vector3(input_direction.x, 0, input_direction.y)
	direction = direction.normalized()
	
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()
