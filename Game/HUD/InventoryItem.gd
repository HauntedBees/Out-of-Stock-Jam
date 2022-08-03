class_name InventoryItem
extends Control

signal equip_position_changed()
signal remove_item()
signal play_sound(sound)

const CAN_MOVE := Color(0, 1, 0, 0.5)
const CANT_MOVE := Color(1, 0, 0, 0.5)

onready var amount_label:Label = $Amount
onready var equip_label:Label = $EquipSlot
onready var item:TextureRect = $Item
onready var movehighlight:ColorRect = $MoveHover
onready var highlight:ColorRect = $Hover
onready var shadow:TextureRect = $Shadow

var search_drag := false
var is_search := false
var parent_container := []
var other_container := []
var num_columns := 0
var equip_order := -1
var info:Item
var dragging := false
var drag_start_pos := Vector2.ZERO

func set_item(i:Item): info = i
func _ready():
	num_columns = 4 if is_search else PlayerInfo.get_inventory_columns()
	if info.max_stack_size > 1:
		hint_tooltip = "%s (%s)" % [info.type, info.amount]
	else:
		hint_tooltip = info.type
	rect_size = 96 * info.size
	item.rect_size = rect_size
	shadow.rect_size = rect_size
	item.texture = load("res://Textures/%s" % info.texture)
	shadow.texture = item.texture
	if info.max_stack_size > 1:
		amount_label.visible = true
		amount_label.text = "x%s" % info.amount
	elif info.uses_ammo:
		amount_label.visible = true
		amount_label.text = String(info.current_ammo)
	set_equip_order()
func set_equip_order():
	if !info.equippable: return
	equip_order = info.equip_index()
	equip_label.visible = !is_search && equip_order >= 0
	if equip_order < 0: return
	equip_label.text = String(equip_order)

func _on_gui_input(event:InputEvent):
	if _is_left_mouse(event):
		var is_pressed := event.is_pressed()
		if is_pressed && info.immediate:
			_immediate_use()
		elif is_pressed && PlayerInfo.inv_drag_to_move:
			_start_item_movement()
		elif !is_pressed:
			if PlayerInfo.inv_drag_to_move || dragging:
				_end_item_movement()
			else:
				_start_item_movement()
	else:
		_handle_maybe_use(event)
func _immediate_use():
	get_tree().call_group("PlayerSound", "play_sound", "Pop")
	match info.type:
		"Rings": get_tree().call_group("player", "add_rings", info.amount)
		#"Mayhem Energy": get_tree().call_group("player", "add_chaos_energy", info.amount)
		"Mayhem Shards": get_tree().call_group("player", "add_emerald_shard", info.amount)
	parent_container.erase(info)
	emit_signal("remove_item")
func _input(event:InputEvent):
	if !highlight.visible: return
	_handle_maybe_use(event)
func _is_left_mouse(event:InputEvent) -> bool:
	if !(event is InputEventMouseButton): return false
	var me:InputEventMouseButton = event
	return me.button_index == 1
func _handle_maybe_use(event:InputEvent):
	var is_hitting_use:bool = (event.is_action("mayhem") && GASInput.is_action_just_pressed("mayhem")) || (event.is_action("use") && GASInput.is_action_just_pressed("use"))
	if !is_hitting_use: return
	if info.immediate:
		_immediate_use()
	elif info.is_usable:
		if PlayerInfo.chaos_energy >= PlayerInfo.max_chaos_energy:
			emit_signal("play_sound", "No")
			return
		else:
			emit_signal("play_sound", "Eat")
			PlayerInfo.chaos_energy = int(min(PlayerInfo.max_chaos_energy * 1.2, PlayerInfo.chaos_energy + info.mayhem_recovered))
			get_tree().call_group("equip_monitor", "update_chaos")
			info.amount -= 1
			if info.amount == 0:
				parent_container.erase(info)
			emit_signal("remove_item")
	elif info.equippable:
		if info.equip_index() < 0:
			emit_signal("play_sound", "No")
			return
		PlayerInfo.current_weapon = info
		get_tree().call_group("equip_monitor", "update_weapon")

func _start_item_movement():
	if PlayerInfo.inv_is_dragging: return # fix for when inv_drag_to_move is true
	emit_signal("play_sound", "Hover")
	dragging = true
	movehighlight.visible = true
	shadow.visible = true
	drag_start_pos = get_viewport().get_mouse_position()
	PlayerInfo.inv_is_dragging = true
func _end_item_movement():
	dragging = false
	shadow.visible = false
	movehighlight.visible = false
	var offset := PlayerInfo.SEARCH_OFFSET if is_search else PlayerInfo.INV_OFFSET
	var other_offset := PlayerInfo.INV_OFFSET if is_search else PlayerInfo.SEARCH_OFFSET
	var other_num_columns := PlayerInfo.get_inventory_columns() if is_search else 4
	if _is_valid_move_location(offset, parent_container):
		emit_signal("play_sound", "Beep")
		if info.max_stack_size > 1:
			var potential_merge := _get_potential_stack(offset, parent_container)
			if potential_merge != null:
				_merge_items(parent_container, potential_merge)
				return
		info.position = _get_shifted_location(offset)
		rect_position = offset + PlayerInfo.INV_DELTA * info.position
	elif (is_search || search_drag) && _is_valid_move_location(other_offset, other_container, other_num_columns):
		emit_signal("play_sound", "Beep")
		if info.max_stack_size > 1:
			var potential_merge := _get_potential_stack(other_offset, other_container)
			if potential_merge != null:
				_merge_items(parent_container, potential_merge)
				return
		info.position = _get_shifted_location(other_offset)
		rect_position = other_offset + PlayerInfo.INV_DELTA * info.position
		_move_between_containers(parent_container, other_container, info)
	else:
		emit_signal("play_sound", "No")
	shadow.rect_position = Vector2.ZERO
	movehighlight.rect_position = Vector2.ZERO
	PlayerInfo.inv_is_dragging = false
	if info.equippable: emit_signal("equip_position_changed")

func _process(_delta:float):
	if !dragging: return
	var new_pos := get_viewport().get_mouse_position()
	var delta := new_pos - drag_start_pos
	shadow.rect_position += delta
	movehighlight.rect_position += delta
	drag_start_pos = new_pos
	var offset := PlayerInfo.SEARCH_OFFSET if is_search else PlayerInfo.INV_OFFSET
	var valid_in_place := _is_valid_move_location(offset, parent_container)
	if valid_in_place:
		movehighlight.color = CAN_MOVE
	elif is_search || search_drag:
		var other_offset := PlayerInfo.INV_OFFSET if is_search else PlayerInfo.SEARCH_OFFSET
		var other_num_columns := PlayerInfo.get_inventory_columns() if is_search else 4
		valid_in_place = _is_valid_move_location(other_offset, other_container, other_num_columns)
		movehighlight.color = CAN_MOVE if valid_in_place else CANT_MOVE
	else:
		movehighlight.color = CANT_MOVE

func _is_valid_move_location(offset:Vector2, container:Array, other_num_columns := 0) -> bool:
	var current_position := _get_shifted_location(offset)
	if current_position.x < 0 || current_position.y < 0: return false
	var potential_end := current_position + info.size - Vector2(1, 1)
	if potential_end.x >= max(num_columns, other_num_columns) || potential_end.y >= PlayerInfo.INV_HEIGHT: return false
	for i in container:
		if i.overlaps_item(info, current_position): return false
	return true

func _get_potential_stack(offset:Vector2, container:Array) -> Item:
	var current_position := _get_shifted_location(offset)
	for i in container:
		if i.overlaps_item(info, current_position, true): return i
	return null

func _move_between_containers(from:Array, to:Array, target:Item):
	from.erase(target)
	to.append(target)
	emit_signal("remove_item")

func _merge_items(container:Array, target:Item):
	var new_amount := target.amount + info.amount
	if new_amount > target.max_stack_size:
		var leftover := new_amount - target.max_stack_size
		target.amount = target.max_stack_size
		info.amount = leftover
	else:
		target.amount += info.amount
		container.erase(info)
	emit_signal("remove_item")

func _get_shifted_location(offset:Vector2) -> Vector2:
	return ((rect_position + shadow.rect_position - offset) / PlayerInfo.INV_DELTA).round()

func _on_mouse_entered():
	if PlayerInfo.inv_is_dragging: return
	highlight.visible = true
	emit_signal("play_sound", "Hover")
func _on_mouse_exited():
	if PlayerInfo.inv_is_dragging: return
	highlight.visible = false
func _on_hide():
	highlight.visible = false
	shadow.visible = false
	movehighlight.visible = false
	shadow.rect_position = Vector2.ZERO
	movehighlight.rect_position = Vector2.ZERO
