class_name InventoryItem
extends Control

signal equip_position_changed()
signal remove_item()

const CAN_MOVE := Color(0, 1, 0, 0.5)
const CANT_MOVE := Color(1, 0, 0, 0.5)

onready var amount_label:Label = $Amount
onready var equip_label:Label = $EquipSlot
onready var item:TextureRect = $Item
onready var movehighlight:ColorRect = $MoveHover
onready var highlight:ColorRect = $Hover
onready var shadow:TextureRect = $Shadow

var equip_order := -1
var info:Item
var dragging := false
var drag_start_pos := Vector2.ZERO

func set_item(i:Item): info = i
func _ready():
	rect_size = 96 * info.size
	item.rect_size = rect_size
	shadow.rect_size = rect_size
	item.texture = load("res://Textures/%s" % info.texture)
	shadow.texture = item.texture
	if info.stackable:
		amount_label.visible = true
		amount_label.text = "x%s" % info.amount
	set_equip_order()

func set_equip_order():
	if !info.equippable: return
	equip_order = info.equip_index()
	equip_label.visible = equip_order >= 0
	if equip_order < 0: return
	equip_label.text = String(equip_order)

func _on_gui_input(event:InputEvent):
	if !(event is InputEventMouseButton): return
	if event.is_pressed() && PlayerInfo.drag_to_move:
		_start_item_movement()
	elif !event.is_pressed():
		if PlayerInfo.drag_to_move || dragging:
			_end_item_movement()
		else:
			_start_item_movement()

func _start_item_movement():
	dragging = true
	movehighlight.visible = true
	shadow.visible = true
	drag_start_pos = get_viewport().get_mouse_position()
	PlayerInfo.inv_is_dragging = true
func _end_item_movement():
	dragging = false
	shadow.visible = false
	movehighlight.visible = false
	if _is_valid_move_location():
		if info.stackable:
			var potential_merge := _get_potential_stack()
			if potential_merge != null:
				_merge_items(potential_merge)
				return
		info.position = _get_shifted_location()
		rect_position = PlayerInfo.INV_OFFSET + PlayerInfo.INV_DELTA * info.position
	shadow.rect_position = Vector2.ZERO
	movehighlight.rect_position = Vector2.ZERO
	PlayerInfo.inv_is_dragging = false
	if info.equippable: emit_signal("equip_position_changed")

func _process(_delta:float):
	if dragging:
		var new_pos := get_viewport().get_mouse_position()
		var delta := new_pos - drag_start_pos
		shadow.rect_position += delta
		movehighlight.rect_position += delta
		drag_start_pos = new_pos
		movehighlight.color = CAN_MOVE if _is_valid_move_location() else CANT_MOVE

func _is_valid_move_location() -> bool:
	var current_position := _get_shifted_location()
	if current_position.x < 0 || current_position.y < 0: return false
	var potential_end := current_position + info.size - Vector2(1, 1)
	if potential_end.x >= PlayerInfo.INV_WIDTH || potential_end.y >= PlayerInfo.INV_HEIGHT: return false
	for i in PlayerInfo.inventory:
		if i.overlaps_item(info, current_position): return false
	return true

func _get_potential_stack() -> Item:
	var current_position := _get_shifted_location()
	for i in PlayerInfo.inventory:
		if i.overlaps_item(info, current_position, true): return i
	return null

func _merge_items(target:Item):
	target.amount += info.amount
	emit_signal("remove_item")

func _get_shifted_location() -> Vector2:
	return ((rect_position + shadow.rect_position - PlayerInfo.INV_OFFSET) / PlayerInfo.INV_DELTA).round()

func _on_mouse_entered():
	if PlayerInfo.inv_is_dragging: return
	highlight.visible = true
func _on_mouse_exited():
	if PlayerInfo.inv_is_dragging: return
	highlight.visible = false
func _on_hide():
	highlight.visible = false
	shadow.visible = false
	movehighlight.visible = false
	shadow.rect_position = Vector2.ZERO
	movehighlight.rect_position = Vector2.ZERO
