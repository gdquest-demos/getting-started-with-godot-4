extends Node2D

@onready var animation_tree = %AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")

func idle():
	state_machine.travel("idle")
	
func walk():
	state_machine.travel("walk")
