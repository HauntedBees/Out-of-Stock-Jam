class_name Entity
extends KinematicBody

onready var highlight:ShaderMaterial = preload("res://HUD/Hover.tres")
var main_mesh:MeshInstance
var name_mesh:MeshInstance

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
