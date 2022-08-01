extends Node

const SEARCH_OFFSET := Vector2(-172, 630)
const INV_OFFSET := Vector2(16, 64)
const INV_DELTA := 96
const INV_WIDTH := 11
const INV_HEIGHT := 3

var UNARMED := Item.new("Unarmed", "", Vector2(0, 0), Vector2(0, 0), {"uses_ammo": false})

# Saved Details
var play_time := 0.0
var rings := 0
var chaos_energy := 10
var max_chaos_energy := 10
var emerald_shards := 6
var map_stickers := []
var mayhem_rubies := 0
var mayhem_levels := {
	"Spindash": 0,
	"Magnet": 0,
	"Mayhem-Modulate": 0,
	"Cloak": 0,
	"Swim": 0,
	"Strength": 0,
	"Weaponry": 0,
	"Hacking": 0,
	"Vision": 0
}
var current_map := "Medical Bay"
var inventory := [
	ContentIndex.get_item("Grenade Launcher", Vector2(2, 0), 1),
	ContentIndex.get_item("Grenade Launcher Ammo", Vector2(6, 0), 7),
	ContentIndex.get_item("Assault Rifle", Vector2(4, 0), 30),
	ContentIndex.get_item("Assault Rifle Ammo", Vector2(1, 0), 120),
	ContentIndex.get_item("Pistol Ammo", Vector2(1, 1), 3),
	ContentIndex.get_item("Pistol Ammo", Vector2(1, 2), 8),
	ContentIndex.get_item("Hammer", Vector2(5, 0)),
	ContentIndex.get_item("Sword", Vector2(7, 0)),
	ContentIndex.get_item("Pistol", Vector2(0, 0), 4)
]
var current_weapon:Item = UNARMED
var current_mayhem := ""
var inv_drag_to_move := true
var crouch_toggle := false
var equip_toggle := false
var mouse_sensitivity := 0.15
var map_infos := {}

# Unsaved
var inv_is_dragging := false
var in_cutscene := false
var paused := false
var time_frozen := false
var invisible := false
var return_timeout := 0.0

func inventory_as_dicts() -> Array:
	var res := []
	for i in inventory:
		res.append(i.as_dict())
	return res

func get_mayhem_level(mayhem_name:String) -> int: return mayhem_levels[mayhem_name]
func increase_mayhem_level(mayhem_name:String): mayhem_levels[mayhem_name] += 1
func get_inventory_columns() -> int: return 8 + get_mayhem_level("Strength") 

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
	if res["collider"] is Entity:
		return res["collider"]
	elif res["collider"] is SecurityControl:
		return res["collider"]
	elif !no_lamps && res["collider"] is Lamp:
		return res["collider"]
	return null

func _process(delta:float): play_time += delta
