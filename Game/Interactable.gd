class_name Interactable
extends Entity

onready var tex:Texture = load("res://Textures/Entities/%s.png" % type)
onready var scrap_tex:Texture = load("res://Textures/Entities/%s.png" % scrap_texture_name)
onready var label:Label = $Viewport/Label
export(String) var scrap_texture_name := "Rubble"
export(bool) var shoot_to_get := false
export(float) var collider_y_scale := 1.0
export(float) var y_scale := 1.0
export(float) var x_scale := 1.0
func _ready():
	main_mesh = $InteractModel
	main_mesh.mesh = main_mesh.mesh.duplicate()
	(main_mesh.mesh as QuadMesh).size.x *= x_scale
	(main_mesh.mesh as QuadMesh).size.y *= y_scale
	var col_shape:CollisionShape = $CollisionShape
	col_shape.shape = col_shape.shape.duplicate()
	(col_shape.shape as BoxShape).extents.y *= collider_y_scale
	material = main_mesh.get_active_material(0).duplicate()
	main_mesh.material_override = material
	material.albedo_texture = tex
	name_mesh = $Name
	refresh_label()

func refresh_label():
	if shoot_to_get || contents.size() == 0:
		label.text = type
	else:
		label.text = "%s (%s)" % [type, contents.size()]

func _die():
	if shoot_to_get:
		if content_name.find("rings_") == 0:
			get_tree().call_group("player", "add_rings", contents[0])
		queue_free()
	else:
		material.albedo_texture = scrap_tex
		($CollisionShape as CollisionShape).disabled = true

