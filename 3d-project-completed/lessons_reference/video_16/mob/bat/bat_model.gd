extends Node3D

@onready var animation_tree = %AnimationTree

func hurt():
	animation_tree.set("parameters/HurtShot/request", true)
