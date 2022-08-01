extends TextureRect

const SIZE := 64.0
const SIZEV := Vector2(SIZE, SIZE)
const HALFV := SIZEV / 2.0
const MOUSE_OFFSET := Vector2(6.0, 6.0) - HALFV

var button_theme:Theme = load("res://HUD/Button.tres")
var sticker_textures := [
	load("res://Textures/HUD/MapStickers/GreyDot.png"),
	load("res://Textures/HUD/MapStickers/BluePostit.png"),
	load("res://Textures/HUD/MapStickers/GreenWow.png"),
	load("res://Textures/HUD/MapStickers/RedWow.png"),
	load("res://Textures/HUD/MapStickers/Lock.png"),
	load("res://Textures/HUD/MapStickers/Warning.png"),
	load("res://Textures/HUD/MapStickers/QuestionMark.png"),
	load("res://Textures/HUD/MapStickers/Why.png")
]

onready var cursor:TextureRect = $Cursor
onready var sticker_box:Control = $Stickers
onready var posted_stickers:Control = $PostedStickers
var current_sticker:TextureRect
var player:Player

func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	var pos := Vector2(0, 0)
	for t in sticker_textures:
		var b := Button.new()
		b.rect_size = SIZEV
		b.theme = button_theme
		b.rect_position = pos * SIZE
		var tr := TextureRect.new()
		tr.rect_size = SIZEV
		tr.expand = true
		tr.texture = t
		tr.modulate.a = 0.8
		tr.mouse_filter = MOUSE_FILTER_PASS
		pos.x += 1
		if pos.x == 2:
			pos.x = 0
			pos.y += 1
		b.connect("pressed", self, "_select_sticker", [tr])
		b.add_child(tr)
		sticker_box.add_child(b)

func clean_up():
	if current_sticker != null:
		current_sticker.queue_free()
		current_sticker = null

func _process(_delta:float):
	if current_sticker != null:
		current_sticker.set_global_position(get_viewport().get_mouse_position() + MOUSE_OFFSET)
	cursor.rect_rotation = -rad2deg(player.rotation.y)
	var ppos := player.global_transform.origin
	cursor.rect_position = rect_size / 2.0 + Vector2(ppos.x * 9.15, ppos.z * 9.0) # magic numbers, good enough

func _on_gui_input(event:InputEvent):
	if !(event.is_action("action") && GASInput.is_action_just_pressed("action")): return
	if current_sticker == null: return
	current_sticker.set_global_position(get_viewport().get_mouse_position() + MOUSE_OFFSET)
	remove_child(current_sticker)
	posted_stickers.add_child(current_sticker)
	current_sticker.modulate.a = 1.0
	current_sticker.connect("gui_input", self, "_on_remove_sticker", [current_sticker])
	current_sticker = null
	save_stickers()

func _on_remove_sticker(event:InputEvent, sticker:TextureRect):
	if !(event.is_action("action") && GASInput.is_action_just_pressed("action")): return
	sticker.queue_free()

func _select_sticker(tr:TextureRect):
	current_sticker = tr.duplicate()
	current_sticker.modulate.a = 0.75
	current_sticker.rect_size = SIZEV * 0.75
	add_child(current_sticker)

func save_stickers():
	var stickers := []
	for s in posted_stickers.get_children():
		stickers.append({
			"texture": sticker_textures.find(s.texture),
			"position": s.rect_position
		})
	PlayerInfo.map_stickers = stickers

func load_existing_stickers():
	for s in posted_stickers.get_children():
		posted_stickers.remove_child(s)
	for s in PlayerInfo.map_stickers:
		var tr := TextureRect.new()
		tr.rect_size = SIZEV * 0.75
		tr.expand = true
		tr.texture = sticker_textures[s["texture"]]
		tr.mouse_filter = MOUSE_FILTER_PASS
		tr.connect("gui_input", self, "_on_remove_sticker", [tr])
		tr.rect_position = s["position"] if s is Vector2 else GASUtils.str2vec2(s["position"])
		posted_stickers.add_child(tr)
