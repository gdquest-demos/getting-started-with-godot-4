extends Node2D

@onready var square = %square

var walking = false 

func _physics_process(delta):
	var axis = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var is_walking_input = axis.length() != 0
	
	if walking != is_walking_input:
		walking = is_walking_input
		if walking: square.walk()
		else: square.idle()
		
	if !is_walking_input: return
	
	position += axis.normalized() * 300.0 * delta
