class_name SecurityControl
extends StaticBody

export(int) var level_requirement := 1
export(String) var first_button_text := "Open Door"
export(NodePath) var first_button_target:NodePath
export(String) var first_button_function := ""

export(String) var second_button_text := "Close Door"
export(NodePath) var second_button_target:NodePath
export(String) var second_button_function := ""

export(String) var third_button_text := "Eat Door"
export(NodePath) var third_button_target:NodePath
export(String) var third_button_function := ""

onready var highlight:ShaderMaterial = preload("res://HUD/Hover.tres")
onready var main_mesh:MeshInstance = $MeshInstance
onready var name_mesh:MeshInstance = $Name
var material:SpatialMaterial
var highlight_timer := 0.0
var cleared := false

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

func button_press(idx:int):
	match idx:
		1:
			var n:Node = get_node(first_button_target)
			if n == null: return
			n.call(first_button_function)
		2:
			var n:Node = get_node(second_button_target)
			if n == null: return
			n.call(second_button_function)
		3:
			var n:Node = get_node(third_button_target)
			if n == null: return
			n.call(third_button_function)
