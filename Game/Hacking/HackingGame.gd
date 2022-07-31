class_name HackingGame
extends Control

signal successful_hack()

onready var blue_texture:Texture = preload("res://Textures/Hacking/BlueSphere.png")
onready var red_texture:Texture = preload("res://Textures/Hacking/RedSphere.png")
const GRID_SIZE := Vector2(84.5, 84.5)

onready var rng := RandomNumberGenerator.new()
onready var grid:TextureRect = $Grid
onready var player:TextureRect = $Grid/Hacker
onready var anim:AnimationPlayer = $AnimationPlayer
onready var hack_button:Button = $HackButton
onready var info_top:Control = $InfoTop
onready var info_bottom:Control = $InfoBottom

var grid_offset := Vector2.ZERO
var player_pos := Vector2.ZERO
var node_map := []
var level := 0
var blues_remaining := 0
var game_over := false

func _ready(): rng.randomize()

func _on_HackButton_pressed():
	if hack_button.disabled: return
	hack_button.visible = false
	game_over = false
	info_top.visible = false
	info_bottom.visible = false

func show_granted():
	game_over = true
	hack_button.visible = false
	anim.play("Success")
	info_top.visible = false
	info_bottom.visible = false

func set_access(allowed:bool):
	info_top.visible = true
	info_bottom.visible = true
	hack_button.visible = true
	game_over = true
	if allowed:
		hack_button.text = "Begin Hacking"
		hack_button.disabled = false
	else:
		hack_button.text = "Hacking Level too Low"
		hack_button.disabled = true

func render_map():
	for g in grid.get_children():
		if g.name == "Hacker": continue
		g.queue_free()
	anim.play("RESET")
	node_map = []
	blues_remaining = 0
	var level_options:Array = LEVELS[level]
	var current_map:PoolStringArray = level_options[rng.randi_range(0, level_options.size() - 1)]
	var size := current_map.size()
	var offset := floor((12.0 - size) / 2.0)
	grid_offset = Vector2(offset, offset)
	for y in size:
		var node_row := []
		var row := current_map[y]
		for x in row.length():
			var type := row[x]
			if type == "x":
				node_row.append(null)
				continue
			var tr := TextureRect.new()
			tr.expand = true
			tr.rect_size = GRID_SIZE
			tr.rect_position = GRID_SIZE * (Vector2(x, y) + grid_offset)
			if type == "B":
				blues_remaining += 1
				tr.texture = blue_texture
			else:
				tr.texture = red_texture
			grid.add_child(tr)
			node_row.append(tr)
		node_map.append(node_row)
	player_pos = Vector2(-1, size - 1) + grid_offset
	player.rect_position = GRID_SIZE * player_pos
	grid.remove_child(player)
	grid.add_child(player)

func _process(_delta:float):
	if game_over: return
	var m := Vector2.ZERO
	if Input.is_action_just_pressed("move_forward"):
		m.y = -1
	elif Input.is_action_just_pressed("move_backward"):
		m.y = 1
	elif Input.is_action_just_pressed("strafe_left"):
		m.x -= 1
	elif Input.is_action_just_pressed("strafe_right"):
		m.x += 1
	if m.length() == 0: return
	var new_pos := player_pos + m
	if new_pos.x < 0 || new_pos.y < 0 || new_pos.x > 11 || new_pos.y > 11: return
	player_pos = new_pos
	player.rect_position = GRID_SIZE * player_pos
	var map_pos := player_pos - grid_offset
	if map_pos.x < 0 || map_pos.y < 0 || map_pos.x >= node_map.size() || map_pos.y >= node_map.size(): return
	#var tile := current_map[map_pos.y][map_pos.x]
	var tile:TextureRect = node_map[map_pos.y][map_pos.x]
	if tile == null: return
	if tile.texture == blue_texture:
		tile.texture = red_texture
		blues_remaining -= 1
	else:
		anim.play("GameOver")
		game_over = true
	if blues_remaining == 0:
		anim.play("Success")
		game_over = true
		emit_signal("successful_hack")

const LEVELS := [
	[ # level one
		[
			"xxxxx",
			"xRRRB",
			"xRBBB",
			"xRBBB",
			"xBBBB"
		]
	],
	[], # level two
	[] # level three
]

