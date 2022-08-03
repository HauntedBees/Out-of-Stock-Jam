class_name Interactable
extends Entity

onready var die_sound:AudioStreamPlayer3D = $BreakStream
onready var tex:Texture = load("res://Textures/Entities/%s.png" % type)
onready var scrap_tex:Texture = load("res://Textures/Entities/%s.png" % scrap_texture_name)
onready var label:Label = $Viewport/Label
export(String) var display_name := ""
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
	if display_name == "":
		display_name = type
	name_mesh = $Name
	refresh_label()

func refresh_label():
	if shoot_to_get || contents.size() == 0:
		label.text = display_name
	else:
		label.text = "%s (%s)" % [display_name, contents.size()]

func _die():
	if shoot_to_get:
		get_tree().call_group("PlayerSound", "play_sound", "Pop")
		if content_name.find("rings_") == 0:
			get_tree().call_group("player", "add_rings", contents[0])
		elif content_name.find("mayhem_") == 0:
			get_tree().call_group("player", "add_chaos_energy", contents[0])
		queue_free()
	else:
		die_sound.play()
		material.albedo_texture = scrap_tex
		($CollisionShape as CollisionShape).disabled = true

func _on_BreakStream_finished(): die_sound.queue_free()
