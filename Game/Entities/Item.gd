class_name Item
extends Node

var id:int
var type:String
var texture:String
var size:Vector2
var amount:int
var position:Vector2
var stackable:bool
var equippable:bool
var uses_ammo:bool

func _init(type:String, texture:String, size:Vector2, position := Vector2.ZERO, amount := 1, 
			stackable := true, equippable := false, uses_ammo := true):
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	id = rng.randi_range(1, 10000)
	self.type = type
	self.texture = texture
	self.size = size
	self.amount = amount
	self.position = position
	self.stackable = stackable
	self.equippable = equippable
	self.uses_ammo = uses_ammo

func equip_index() -> int:
	var item_positions := []
	for i in PlayerInfo.inventory:
		if !i.equippable: continue
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
	if i.type == type && stackable && !alert_on_overlap: return false
	var p := i.position if new_position.x < 0 else new_position
	for dx in size.x:
		for dy in size.y:
			var pos := position + Vector2(dx, dy)
			for dxi in i.size.x:
				for dyi in i.size.y:
					var posi := p + Vector2(dxi, dyi)
					if pos == posi: return true
	return false
