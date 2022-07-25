extends Node

const SEARCH_OFFSET := Vector2(-172, 630)
const INV_OFFSET := Vector2(16, 64)
const INV_DELTA := 96
const INV_WIDTH := 11
const INV_HEIGHT := 3

var rings := 0
var chaos_energy := 10
var max_chaos_energy := 10
var emerald_shards := 6

var drag_to_move := true
var inventory_columns := 8

var inv_is_dragging := false

var inventory := [
	Item.new("Pistol Ammo", "Weapons/PistolAmmo.png", Vector2(1, 1), Vector2(1, 1), 3),
	Item.new("Pistol Ammo", "Weapons/PistolAmmo.png", Vector2(1, 1), Vector2(1, 2), 3),
	Item.new("Hammer", "Weapons/Hammer.png", Vector2(1, 3), Vector2(5, 0), 1, false, true, false),
	Item.new("Pistol", "Weapons/Pistol.png", Vector2(1, 3), Vector2(0, 0), 1, false, true)
]
var current_weapon:Item = inventory[2]

func get_ammo(type := "") -> int:
	if type == "": type = current_weapon.type
	var amount := 0
	for i in inventory:
		if i.type == ("%s Ammo" % type): amount += i.amount
	return amount

func reduce_ammo(type := ""):
	if type == "": type = current_weapon.type
	for i in inventory.size():
		var item:Item = inventory[i]
		if item.type != ("%s Ammo" % type): continue
		item.amount -= 1
		if item.amount <= 0:
			inventory.remove(i)
		get_tree().call_group("equip_monitor", "update_ammo")
		return

func get_collision(distance:float) -> Entity:
	var camera := get_viewport().get_camera()
	var center := get_viewport().size / 2
	var from := camera.project_ray_origin(center)
	var to := from + camera.project_ray_normal(center) * distance
	var res := get_viewport().world.direct_space_state.intersect_ray(from, to)
	if !res.has("collider"): return null
	return res["collider"] if res["collider"] is Entity else null
