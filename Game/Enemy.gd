class_name Enemy
extends Entity

const PI_QTR := PI/4
const PI_THREEQTR := PI_QTR * 3.0

export(bool) var is_human := true
export(float) var speed := 400.0

onready var player:Spatial = get_parent().find_node("Player")
onready var nav:Navigation = get_parent()
var path := []
var path_node := 0
onready var mind:Timer = $ThinkTimer

onready var front:Texture = load("res://Textures/Entities/%s_Front.png" % type)
onready var side:Texture = load("res://Textures/Entities/%s_Side.png" % type)
onready var back:Texture = load("res://Textures/Entities/%s_Back.png" % type)
onready var hurt:Texture = load("res://Textures/Entities/%s_Hurt.png" % type)
onready var dead:Texture = load("res://Textures/Entities/%s.png" % ("corpse" if is_human else "Rubble"))
onready var timer:Timer = $Timer
onready var label:Label = $Viewport/Label

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
	d["is_human"] = is_human
	d["speed"] = speed
	return d

func _ready():
	main_mesh = $EnemyModel
	name_mesh = $Name
	material = main_mesh.get_active_material(0).duplicate()
	main_mesh.material_override = material
	material.albedo_texture = front
	label.text = type

func _process(_delta:float):
	if PlayerInfo.paused || hit_anim || is_dead: return
	_set_animation()

func _physics_process(delta:float):
	if PlayerInfo.paused || PlayerInfo.time_frozen: return
	if hit_anim || is_dead: return
	if path_node < path.size():
		var dir:Vector3 = (path[path_node] - global_transform.origin)
		dir.y = -0.2
		if dir.length() <= 0.5:
			path_node += 1
		else:
			move_and_slide(dir.normalized() * speed * delta, Vector3.UP)

func _look_at_target(t:Vector3):
	look_at(t, Vector3.UP)
	rotation.x = 0
	rotation.z = 0
	_set_animation(true)
func _set_target(t:Vector3, face_target := false):
	if face_target: _look_at_target(t)
	path = nav.get_simple_path(global_transform.origin, t)
	path_node = 0

# avencherus you are my hero I spent 3 hours trying to remember trigonometry and you saved my life
# https://godotengine.org/qa/27625/equivalent-of-gamemakerss-function-angle_difference?show=27631#a27631
func _angle_to_angle(from:float, to:float) -> float: return fposmod(to - from + PI, PI * 2) - PI
func _vector3_to_vector2(v3:Vector3) -> Vector2: return Vector2(v3.x, v3.z).normalized()

# front = 1/2, right = 1, back = -1/2, left = 0
func _set_animation(forced := false):
	if is_dead: return
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

func _on_mind_timeout():
	if PlayerInfo.time_frozen: return
	if hit_anim || is_dead: return
	if PlayerInfo.invisible: return
	_set_target(player.global_transform.origin, true)

func _get_light_level() -> int:
	var lights := get_tree().get_nodes_in_group("light")
	var light_amount := 0
	var state := get_viewport().world.direct_space_state
	var to := global_transform.origin
	for l in lights:
		var from := (l as StaticBody).global_transform.origin
		var res := state.intersect_ray(from, to)
		if !res.has("collider"): continue
		if res["collider"] == self: light_amount += 1
	return light_amount

func _get_player_light_level() -> int:
	if PlayerInfo.invisible: return 0
	var lights := get_tree().get_nodes_in_group("light")
	var light_amount := 0
	var state := get_viewport().world.direct_space_state
	var to := player.global_transform.origin
	for l in lights:
		var from := (l as StaticBody).global_transform.origin
		var res := state.intersect_ray(from, to)
		if !res.has("collider"): continue
		if res["collider"] == player: light_amount += 1
	return light_amount
	
