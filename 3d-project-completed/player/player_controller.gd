# Note: Name this by the name of the final player mesh, do not keep the file name
# "character_body_3d"
extends CharacterBody3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	%Marker3D.look_at(%Camera3D.global_position + %Camera3D.global_transform.basis.z * 1000)
	%Marker3D.rotation_degrees.y += 2.0


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5
		%Camera3D.rotation_degrees.x -= event.relative.y * 0.2
		%Camera3D.rotation_degrees.x = clamp(%Camera3D.rotation_degrees.x, -80, 80)
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
		if velocity.y > 0.0 and not Input.is_action_pressed("jump"):
			velocity.y = 0.0
	elif Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

	move_and_slide()

	if Input.is_action_pressed("shoot") and %Timer.is_stopped():
		shoot_bullet()


func shoot_bullet():
	const MAX_RECOIL_ANGLE = 2.0

	var new_bullet = preload("bullet_3d.tscn").instantiate()
	%Marker3D.add_child(new_bullet)
	new_bullet.transform = %Marker3D.global_transform
	new_bullet.rotation_degrees.x += randf_range(-MAX_RECOIL_ANGLE, MAX_RECOIL_ANGLE)
	new_bullet.rotation_degrees.y += randf_range(-MAX_RECOIL_ANGLE, MAX_RECOIL_ANGLE)
	%Timer.start()
	
	%ShotSound.pitch_scale = randfn(1.0, 0.1)
	%ShotSound.play()
	
	%PlasmaGun.shoot()
