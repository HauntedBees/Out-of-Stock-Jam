class_name Enemy
extends Entity

const PI_QTR := PI/4
const PI_THREEQTR := PI_QTR * 3.0

export(bool) var is_human := true

onready var front:Texture = load("res://Textures/Entities/%s_Front.png" % type)
onready var side:Texture = load("res://Textures/Entities/%s_Side.png" % type)
onready var back:Texture = load("res://Textures/Entities/%s_Back.png" % type)
onready var hurt:Texture = load("res://Textures/Entities/%s_Hurt.png" % type)
onready var dead:Texture = load("res://Textures/Entities/corpse.png")
onready var timer:Timer = $Timer
onready var label:Label = $Viewport/Label

var last_h_angle := 0.0
var hit_anim := false

func _ready():
	main_mesh = $EnemyModel
	name_mesh = $Name
	material = main_mesh.get_active_material(0)
	main_mesh.material_override = material
	material.albedo_texture = front
	label.text = type

# front = -1/2, right = 0, back = 1/2, left = 1
func _process(delta:float):
	if hit_anim || is_dead: return
	_set_animation()

func _set_animation(forced := false):
	var camera:Camera = get_viewport().get_camera()
	var heading := camera.global_transform.origin.direction_to(global_transform.origin)
	var h_xz := Vector2(heading.x, heading.z)
	var h_angle := h_xz.angle()
	if !forced && abs(h_angle - last_h_angle) < 0.25: return # reduce calls to everything below
	last_h_angle = h_angle
	var abs_h_angle := abs(h_angle)
	material.uv1_scale.x = 1
	if abs_h_angle >= PI_THREEQTR: # left
		material.albedo_texture = side
	elif abs_h_angle <= PI_QTR: # right
		material.albedo_texture = side
		material.uv1_scale.x = -1
	elif h_angle < 0: # front
		material.albedo_texture = front
	else:# back
		material.albedo_texture = back

func _hit_animation():
	material.uv1_scale.x = 1
	material.albedo_texture = hurt
	hit_anim = true
	timer.start(0.25)
	yield(timer, "timeout")
	hit_anim = false
	_set_animation(true)

func _die():
	material.uv1_scale.x = 1
	material.albedo_texture = dead
	(main_mesh.mesh as QuadMesh).size = Vector2(0.75, 1.0)
	translate(Vector3(0, -0.5, 0))
	refresh_label()
	# keep collider for looting, but prevent player collision 
	collision_layer = 2
	collision_mask = 2

func refresh_label():
	var amount := contents.size()
	var title := "Corpse" if is_human else "Scrap"
	if amount == 0: label.text = title
	else: label.text = "%s (%s)" % [title, amount]
