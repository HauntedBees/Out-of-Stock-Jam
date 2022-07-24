class_name InventoryItem
extends TextureRect

onready var highlight:ColorRect = $Hover
var dragging := false
var drag_start_pos := Vector2.ZERO

func set_item(d:Dictionary):
	rect_size = 96 * d["size"]
	if d.has("flip_texture"):
		rect_size = Vector2(rect_size.y, rect_size.x)
		rect_rotation = 90
	texture = load("res://Textures/%s" % d["texture"])

func _on_gui_input(event:InputEvent):
	if !(event is InputEventMouseButton): return
	if event.is_pressed() && PlayerInfo.drag_to_move:
		dragging = true
		drag_start_pos = get_viewport().get_mouse_position()

func _process(_delta:float):
	if dragging:
		var new_pos := get_viewport().get_mouse_position()
		var delta := new_pos - drag_start_pos
		rect_position += delta
		drag_start_pos = new_pos

func _on_mouse_entered():
	highlight.visible = true

func _on_mouse_exited():
	highlight.visible = false

func _on_hide():
	highlight.visible = false
