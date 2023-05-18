extends Node3D
class_name Switch3D

var state = false : set = set_state

signal state_changed(state : bool)

func set_state(v : bool):
	if state == v: return
	state = v
	state_changed.emit(state)
