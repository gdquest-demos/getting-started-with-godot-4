extends Node3D
class_name Connector

@export var switch_nps: Array[NodePath] = []
@onready var switches = switch_nps.map(get_node)

var state = false : set = set_state

signal state_changed(state : bool)

func _ready():
	return
	for switch in switches:
		switch.connect("state_changed", check_switches)

func check_switches(_switch_state):
	state = switches.all(func(switch):
		return switch.state
		)

func set_state(value : bool):
	if state == value: return
	state = value
	on_state_change()

func on_state_change():
	pass
