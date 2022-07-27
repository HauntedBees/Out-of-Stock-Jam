class_name Interactable
extends Entity

onready var tex:Texture = load("res://Textures/Entities/%s.png" % type)
onready var label:Label = $Viewport/Label
export(bool) var shoot_to_get := false
export(float) var y_scale := 1.0
func _ready():
	main_mesh = $InteractModel
	(main_mesh.mesh as QuadMesh).size.y *= y_scale
	material = main_mesh.get_active_material(0).duplicate()
	main_mesh.material_override = material
	material.albedo_texture = tex
	name_mesh = $Name
	refresh_label()

func refresh_label():
	if shoot_to_get:
		label.text = type
	else:
		label.text = "%s (%s)" % [type, contents.size()]

func _die():
	if shoot_to_get:
		if content_name.find("rings_") == 0:
			get_tree().call_group("player", "add_rings", contents[0])
	else:
		print("he was destroyed")
	queue_free()

