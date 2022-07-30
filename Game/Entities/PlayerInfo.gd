extends Node

const SEARCH_OFFSET := Vector2(-172, 630)
const INV_OFFSET := Vector2(16, 64)
const INV_DELTA := 96
const INV_WIDTH := 11
const INV_HEIGHT := 3

var UNARMED := Item.new("Unarmed", "", Vector2(0, 0), Vector2(0, 0), {"uses_ammo": false})

var rings := 0
var chaos_energy := 10
var max_chaos_energy := 10
var emerald_shards := 6

var drag_to_move := true
var inventory_columns := 8

var inv_is_dragging := false
var in_cutscene := false

var map_to_load := "Medical Bay"

var mayhem_levels := {
	"Spindash": 1,
	"Magnet": 1
}

func get_mayhem_level(mayhem_name:String) -> int: return mayhem_levels[mayhem_name]
func increase_mayhem_level(mayhem_name:String): mayhem_levels[mayhem_name] += 1

var inventory := [
	Item.new("Pistol Ammo", "Weapons/PistolAmmo.png", Vector2(1, 1), Vector2(1, 1), {"amount": 3}),
	Item.new("Pistol Ammo", "Weapons/PistolAmmo.png", Vector2(1, 1), Vector2(1, 2), {"amount": 8}),
	Item.new("Hammer", "Weapons/Hammer.png", Vector2(1, 3), Vector2(5, 0), { "equippable": true, "uses_ammo": false }),
	Item.new("Pistol", "Weapons/Pistol.png", Vector2(1, 3), Vector2(0, 0), { "equippable": true, "reload_amount": 6, "current_ammo": 4, "reload_speed_mult": 0.2 })
]
var current_weapon:Item = UNARMED
var current_mayhem := ""

func get_loaded_ammo() -> int: return current_weapon.current_ammo
func get_ammo() -> int:
	var type := current_weapon.type
	var amount := 0
	for i in inventory:
		if i.type == ("%s Ammo" % type): amount += i.amount
	return amount

func reduce_ammo():
	current_weapon.current_ammo -= 1
	get_tree().call_group("equip_monitor", "update_ammo")

func reload_weapon():
	var type := current_weapon.type
	var remaining := current_weapon.reload_amount - current_weapon.current_ammo
	var indexes_to_remove := []
	for i in inventory.size():
		var item:Item = inventory[i]
		if item.type != ("%s Ammo" % type): continue
		if item.amount >= remaining:
			item.amount -= remaining
			remaining = 0
		else:
			remaining -= item.amount
			item.amount = 0
		if item.amount <= 0: indexes_to_remove.append(i)
		if remaining == 0: break
	for i in indexes_to_remove: inventory.remove(i)
	current_weapon.current_ammo = current_weapon.reload_amount - remaining
	get_tree().call_group("equip_monitor", "update_ammo")

func get_collision(distance:float, no_lamps := false) -> Entity:
	var camera := get_viewport().get_camera()
	var center := get_viewport().size / 2
	var from := camera.project_ray_origin(center)
	var to := from + camera.project_ray_normal(center) * distance
	var res := get_viewport().world.direct_space_state.intersect_ray(from, to)
	if !res.has("collider"): return null
	return res["collider"] if res["collider"] is Entity || (!no_lamps && res["collider"] is Lamp) else null
