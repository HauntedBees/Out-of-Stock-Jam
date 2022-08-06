class_name Item
extends Node

var id:int
var type:String
var texture:String
var size:Vector2
var amount:int
var position:Vector2
var max_stack_size:int
var equippable:bool
var uses_ammo:bool
var reload_amount:int
var reload_speed_mult:float
var current_ammo:int
var is_heavy:bool
var is_usable:bool
var immediate:bool
var mayhem_recovered:int
var saved_args:Dictionary

func _init(item_type:String, texture_path:String, inv_size:Vector2, inv_pos := Vector2.ZERO, other := {}):
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	id = rng.randi_range(1, 10000)
	type = item_type
	texture = texture_path
	size = inv_size
	position = inv_pos
	saved_args = other
	amount = other["amount"] if other.has("amount") else 1
	equippable = other.has("equippable")
	immediate = other.has("immediate")
	is_heavy = other.has("is_heavy")
	max_stack_size = other["max_stack_size"] if other.has("max_stack_size") else 1
	uses_ammo = other["uses_ammo"] if other.has("uses_ammo") else true
	reload_amount = other["reload_amount"] if other.has("reload_amount") else 0
	current_ammo = other["current_ammo"] if other.has("current_ammo") else reload_amount
	reload_speed_mult = other["reload_speed_mult"] if other.has("reload_speed_mult") else 1.0
	is_usable = other.has("usable")
	mayhem_recovered = other["mayhem_recovered"] if other.has("mayhem_recovered") else 0

func as_dict() -> Dictionary:
	return {
		"type": type,
		"amount": current_ammo if equippable else amount,
		"position": position
	}

func equip_index() -> int:
	var can_equip_heavy:bool = PlayerInfo.get_mayhem_level("Weaponry") > 0
	if is_heavy && !can_equip_heavy: return -1
	var item_positions := []
	for i in PlayerInfo.inventory:
		if !i.equippable: continue
		if i.is_heavy && !can_equip_heavy: continue
		item_positions.append(i.position)
	item_positions.sort_custom(self, "_pos_sort")
	var idx := item_positions.find(position)
	if idx > 10: return -1
	elif idx == 10: return 0
	else: return idx + 1
func _pos_sort(a:Vector2, b:Vector2) -> bool:
	if a.x == b.x: return a.y < b.y
	else: return a.x < b.x

func overlaps_item(i:Item, new_position:Vector2 = Vector2(-1, -1), alert_on_overlap := false) -> bool:
	if i.id == id: return false
	if i.type == type && max_stack_size > 1 && !alert_on_overlap: return false
	var p := i.position if new_position.x < 0 else new_position
	for dx in size.x:
		for dy in size.y:
			var pos := position + Vector2(dx, dy)
			for dxi in i.size.x:
				for dyi in i.size.y:
					var posi := p + Vector2(dxi, dyi)
					if pos == posi: return true
	return false
