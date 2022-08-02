class_name Enemy
extends Entity

var animal_scene:PackedScene = preload("res://Entities/Particles/Animal.tscn")
var dead_mesh:QuadMesh = preload("res://Entities/DeadMesh.tres")

const PI_QTR := PI/4
const PI_THREEQTR := PI_QTR * 3.0
export(Script) var enemy_ai:Script
export(bool) var is_human := true
export(float) var speed := 400.0
export(bool) var all_facing := false

onready var only_texture:Texture = null if !all_facing else load("res://Textures/Entities/%s.png" % type)
onready var front:Texture = null if all_facing else load("res://Textures/Entities/%s_Front.png" % type)
onready var side:Texture = null if all_facing else load("res://Textures/Entities/%s_Side.png" % type)
onready var back:Texture = null if all_facing else load("res://Textures/Entities/%s_Back.png" % type)
onready var hurt:Texture = load("res://Textures/Entities/%s_Hurt.png" % type)
onready var dead:Texture = load("res://Textures/Entities/%s.png" % ("corpse" if is_human else "Rubble"))
onready var timer:Timer = $Timer
onready var label:Label = $Viewport/Label
onready var die_sound:AudioStreamPlayer3D = $PopStream
onready var misc_sound:AudioStreamPlayer3D = $MiscStream

var my_ai:EnemyAI = null
var last_h_angle := 0.0
var hit_anim := false

func from_dict(d:Dictionary):
	last_h_angle = d["last_h_angle"]
	hit_anim = d["hit_anim"]
	is_human = d["is_human"]
	speed = d["speed"]
	_entity_from_dict(d)
func as_dict() -> Dictionary:
	var d := _entity_as_dict()
	d["last_h_angle"] = last_h_angle
	d["hit_anim"] = hit_anim
	# these next two PROBABLY aren't needed but eh
	d["is_human"] = is_human
	d["speed"] = speed
	return d

func _ready():
	if enemy_ai != null:
		my_ai = enemy_ai.new()
		add_child(my_ai)
	main_mesh = $EnemyModel
	name_mesh = $Name
	material = main_mesh.get_active_material(0).duplicate()
	main_mesh.material_override = material
	material.albedo_texture = only_texture if all_facing else front
	label.text = type

func _process(_delta:float):
	if PlayerInfo.paused || hit_anim || is_dead: return
	_set_animation()

func _custom_hit():
	if my_ai == null: return
	my_ai.is_hit()

# avencherus you are my hero I spent 3 hours trying to remember trigonometry and you saved my life
# https://godotengine.org/qa/27625/equivalent-of-gamemakerss-function-angle_difference?show=27631#a27631
func _angle_to_angle(from:float, to:float) -> float: return fposmod(to - from + PI, PI * 2) - PI
func _vector3_to_vector2(v3:Vector3) -> Vector2: return Vector2(v3.x, v3.z).normalized()

# front = 1/2, right = 1, back = -1/2, left = 0
func _set_animation(forced := false):
	if is_dead: return
	if all_facing:
		material.albedo_texture = only_texture
		return
	var camera:Camera = get_viewport().get_camera()
	
	var forward := Vector2(0, 1)
	var camera_angle := _vector3_to_vector2(camera.global_transform.basis.z).angle_to(forward)
	var enemy_angle := _vector3_to_vector2(global_transform.basis.z).angle_to(forward)
	
	var h_angle := _angle_to_angle(enemy_angle, camera_angle)
	if !forced && abs(h_angle - last_h_angle) < 0.25: return # reduce calls to everything below
	last_h_angle = h_angle
	var abs_h_angle := abs(h_angle)
	
	material.uv1_scale.x = 1
	if abs_h_angle > PI_THREEQTR: # front approaches PI or -PI
		material.albedo_texture = front
	elif abs_h_angle < PI_QTR: # back approaches 0
		material.albedo_texture = back
	elif h_angle > 0: # right side is around PI/2
		material.albedo_texture = side
		material.uv1_scale.x = -1
	else: # left side is around -PI/2
		material.albedo_texture = side

func _hit_animation():
	if is_dead: return
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
	main_mesh.mesh = dead_mesh
	if !is_human:
		var animal:Spatial = animal_scene.instance()
		get_parent().add_child(animal)
		animal.global_transform.origin = global_transform.origin
		die_sound.play()
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

func _on_PopStream_finished(): die_sound.queue_free()

func play_misc_sound(s:AudioStream):
	misc_sound.stream = s
	misc_sound.play()
