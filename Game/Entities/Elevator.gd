class_name Elevator
extends Spatial

export(String, "REGULAR", "SERVICE", "EXECUTIVE") var type := "REGULAR"
onready var highlight:ShaderMaterial = preload("res://HUD/Hover.tres")
onready var main_mesh:MeshInstance = $MeshInstance
onready var name_mesh:MeshInstance = $Name
var material:SpatialMaterial
var highlight_timer := 0.0

func _ready():
	main_mesh.mesh = main_mesh.mesh.duplicate()
	material = main_mesh.get_active_material(0).duplicate()
	main_mesh.material_override = material

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
