extends Node

@export var pistol_anchor : Marker2D
@export var pistol : Node2D
@export var projectile_scene : PackedScene
@export var muzzle_flash_scene : PackedScene
@export var impact_scene : PackedScene

func _process(delta):
	pistol_anchor.rotate(1.0 * delta)
	if Input.is_action_just_pressed("jump"): shoot()
	
func shoot():
	pistol.shoot()
	
	var flash = muzzle_flash_scene.instantiate()
	flash.global_position = pistol.end.global_position
	flash.rotation = pistol.end.global_rotation
	add_child(flash)
	
	var projectile = projectile_scene.instantiate()
	projectile.global_position = pistol.end.global_position
	projectile.rotation = pistol_anchor.rotation
	add_child(projectile)
	
	projectile.connect("impact", on_impact)

func on_impact(impact_position):
	var impact = impact_scene.instantiate()
	impact.global_position = impact_position
	add_child(impact)
