## Suggestion for different phases of the tutorial

class Phase_1 extends CharacterBody3D:
	
	func _physics_process(delta):
		var input_direction_2D = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var input_direction_3D = Vector3(input_direction_2D.x, 0, input_direction_2D.y)
		var direction = transform.basis * input_direction_3D
		direction = direction.normalized()
		
		velocity.x = direction.x * 5.5
		velocity.z = direction.z * 5.5

		move_and_slide()

class Phase_2 extends Phase_1:
	
	# +
	func _unhandled_input(event):
		if event is InputEventMouseMotion:
			rotation_degrees.y -= event.relative.x * 0.5
			rotation_degrees.x -= event.relative.y * 0.5
	# /

	func _physics_process(delta):
		var input_direction_2D = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var input_direction_3D = Vector3(input_direction_2D.x, 0, input_direction_2D.y)
		var direction = transform.basis * input_direction_3D
		direction = direction.normalized()
		
		velocity.x = direction.x * 5.5
		velocity.z = direction.z * 5.5
		# +
		velocity.y -= 20 * delta
		
		if Input.is_action_just_pressed("jump"):
			velocity.y = 10
		# /
		move_and_slide()

class Phase_3 extends Phase_2:
	func _physics_process(delta):
		# +
		const SPEED = 5.5
		const GRAVITY = 20
		const JUMP_VELOCITY = 10
		# /
		var input_direction_2D = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var input_direction_3D = Vector3(input_direction_2D.x, 0, input_direction_2D.y)
		var direction = transform.basis * input_direction_3D
		direction = direction.normalized()
		
		# change
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		velocity.y -= GRAVITY * delta
		
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
		# /
		move_and_slide()

class Phase_4 extends Phase_3:
	func _physics_process(delta):
		const SPEED = 5.5
		const GRAVITY = 20
		const JUMP_VELOCITY = 10

		var input_direction_2D = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var input_direction_3D = Vector3(input_direction_2D.x, 0, input_direction_2D.y)
		var direction = transform.basis * input_direction_3D
		direction = direction.normalized()
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# +
		if not is_on_floor():
			velocity.y -= GRAVITY * delta
		# /
		elif Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY

		move_and_slide()

class Phase_5 extends Phase_4:
	func _unhandled_input(event):
		if event is InputEventMouseMotion:
			rotation_degrees.y -= event.relative.x * 0.5
			# change
			rotation_degrees.x = clamp(rotation_degrees.x - event.relative.y / 5, -80, 80)
			# /


class Phase_6 extends Phase_5:
	# +
	func _ready():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# /


	func _unhandled_input(event):
		if event is InputEventMouseMotion:
			rotation_degrees.y -= event.relative.x * 0.5
			rotation_degrees.x = clamp(rotation_degrees.x - event.relative.y / 5, -80, 80)
		# +
		elif event.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		# /

