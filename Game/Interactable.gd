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
	main_mesh.mesh = MeshCache.get_mesh_with_dimensions(main_mesh.mesh, Vector2(x_scale, y_scale))
	var col_shape:CollisionShape = $CollisionShape
	col_shape.shape = MeshCache.get_collider_with_dimensions(col_shape.shape, Vector2(1.0, collider_y_scale))
	main_mesh.material_override = MeshCache.get_material_with_texture(main_mesh.get_active_material(0), tex)
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
		transform.origin.y -= 0.5
		main_mesh.material_override = MeshCache.get_material_with_texture(main_mesh.material_override, scrap_tex)
		($CollisionShape as CollisionShape).disabled = true

func _on_BreakStream_finished(): die_sound.queue_free()
