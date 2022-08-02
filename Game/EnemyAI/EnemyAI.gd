class_name EnemyAI
extends Node

onready var e := get_parent()
onready var mind := Timer.new()
onready var player:Spatial = e.get_parent().find_node("Player")
onready var nav:Navigation = e.get_parent()

var path := []
var path_node := 0

func _ready():
	add_child(mind)
	mind.autostart = true
	mind.one_shot = false
	mind.start()
	mind.connect("timeout", self, "_on_mind_timeout")

func _custom_mind_timeout(): return
func _on_mind_timeout():
	if PlayerInfo.time_frozen: return
	if e.hit_anim || e.is_dead: return
	if PlayerInfo.invisible: return
	_custom_mind_timeout()

func _custom_physics_process(_delta:float): return
func _physics_process(delta:float):
	if PlayerInfo.paused || PlayerInfo.time_frozen: return
	if e.hit_anim || e.is_dead: return
	_custom_physics_process(delta)
	
func _custom_process(_delta:float): return
func _process(delta:float):
	if PlayerInfo.paused || PlayerInfo.time_frozen: return
	if e.hit_anim || e.is_dead: return
	_custom_process(delta)

func _look_at_target(t:Vector3):
	e.look_at(t, Vector3.UP)
	e.rotation.x = 0
	e.rotation.z = 0
	e._set_animation(true)

func _set_target(t:Vector3, face_target := false):
	if face_target: _look_at_target(t)
	path = nav.get_simple_path(e.global_transform.origin, t)
	path_node = 0

func _get_light_level() -> int:
	var lights := get_tree().get_nodes_in_group("light")
	var light_amount := 0
	var state := get_viewport().world.direct_space_state
	var to:Vector3 = e.global_transform.origin
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