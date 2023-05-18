extends Node2D

@onready var animation_tree = %AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
@onready var hurt_shot_path = "parameters/HurtShot/request"

func play_idle():
	state_machine.travel("idle")
	
func play_walk():
	state_machine.travel("walk")
	
func play_hurt():
	animation_tree.set(hurt_shot_path, true)
