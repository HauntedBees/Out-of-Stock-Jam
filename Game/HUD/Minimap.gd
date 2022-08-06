tool
extends Control

const INITIAL_POS := Vector2(20.0, 20.0) # magic number

onready var cursor:TextureRect = $Cursor
onready var map:TextureRect = $Map
export(Vector2) var offset := Vector2(0, 0) setget _set_offset
export(float) var rotation := 0.0 setget _set_rotation

var player:Player
var origin_real_position:Vector2
var origin_mini_position:Vector2

func _set_offset(v:Vector2):
	offset = v
	if !is_inside_tree(): return
	if map == null: map = $Map
	map.rect_position = INITIAL_POS - offset * 420.0 # magic number
	(map.material as ShaderMaterial).set_shader_param("offset", offset)

func _set_rotation(f:float):
	rotation = -rad2deg(f)
	if !is_inside_tree(): return
	if cursor == null: cursor = $Cursor
	cursor.rect_rotation = rotation

func _ready(): reset()

func reset():
	if PlayerInfo.current_map == "CommandCenter":
		visible = false
		return
	else:
		visible = true
	map.texture = load("res://Textures/HUD/Map_%s.png" % PlayerInfo.current_map)
	var map_origin := get_tree().get_nodes_in_group("MapOrigin")
	if map_origin == null || map_origin.size() == 0: return
	var origin:MapOrigin = map_origin[0]
	player = get_tree().get_nodes_in_group("player")[0]
	origin_real_position = Vector2(origin.global_transform.origin.x, origin.global_transform.origin.z)
	origin_mini_position = origin.offset
	_set_offset(origin_mini_position)
	_set_rotation(player.rotation.y)

func _process(_delta:float):
	if Engine.editor_hint || PlayerInfo.current_map == "CommandCenter": return
	if player == null: return
	var player_origin := Vector2(player.global_transform.origin.x, player.global_transform.origin.z)
	var player_offset := player_origin - origin_real_position
	_set_offset(origin_mini_position + Vector2(player_offset.x / 21.0, player_offset.y / 20.5)) # magic numbers
	_set_rotation(player.rotation.y)
