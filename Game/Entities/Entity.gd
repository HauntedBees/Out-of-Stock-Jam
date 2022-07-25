class_name Entity
extends KinematicBody

onready var highlight:ShaderMaterial = preload("res://HUD/Hover.tres")
var main_mesh:MeshInstance
var name_mesh:MeshInstance

var forced_velocity := Vector3.ZERO
var forced_velocity_timer := 0.0

var highlight_timer := 0.0

func show_highlight():
	highlight_timer = 0.1
	main_mesh.get_active_material(0).next_pass = highlight
	name_mesh.visible = true

func _process(delta:float):
	if highlight_timer > 0:
		highlight_timer -= delta
		if highlight_timer < 0: hide_highlight()

func hide_highlight():
	main_mesh.get_active_material(0).next_pass = null
	name_mesh.visible = false

func take_hit(direction:Vector3, force:float, _damage:float):
	forced_velocity = direction * force
	forced_velocity.y = 0.0
	forced_velocity_timer = 0.2
	# TODO: take damage

func _physics_process(delta:float):
	if forced_velocity_timer >= 0.0:
		move_and_slide(forced_velocity * delta, Vector3.UP)
		forced_velocity_timer -= delta
