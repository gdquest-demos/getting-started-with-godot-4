# Note: Name this by the name of the final player mesh, do not keep the file name
# "character_body_3d"
extends CharacterBody3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5
		rotation_degrees.x -= event.relative.y * 0.2
		rotation_degrees.x = clamp(rotation_degrees.x, -80, 80)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta):
	const SPEED = 5.5
	const GRAVITY = 20
	const JUMP_VELOCITY = 10

	var input_direction_2D = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var input_direction_3D = Vector3(input_direction_2D.x, 0, input_direction_2D.y)
	var direction = transform.basis * input_direction_3D
	direction.y = 0.0
	direction = direction.normalized()
	
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

	move_and_slide()
