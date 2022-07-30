class_name Inventory
extends Control

signal close_search()

onready var tooltip_theme:Theme = preload("res://HUD/Tooltip.tres")
onready var mayhem:PackedScene = preload("res://HUD/InventoryMayhem.tscn")
onready var item:PackedScene = preload("res://HUD/InventoryItem.tscn")
onready var tile:TextureRect = $TileRect
onready var lock:TextureRect = $LockedRect

const MAYHEM_OFFSET := PlayerInfo.INV_OFFSET + Vector2(12.0 * PlayerInfo.INV_DELTA, 0.0)
const MAYHEMS := ["Spindash", "Magnet", "Mayhem-Modulate", "Cloak"]
onready var mayhem_textures := {
	"Spindash": preload("res://Textures/Entities/Mayhem/Spindash.png"),
	"Magnet": preload("res://Textures/Entities/Mayhem/Magnet.png"),
	"Mayhem-Modulate": preload("res://Textures/Entities/Mayhem/Mayhem-Modulate.png"),
	"Cloak": preload("res://Textures/Entities/Mayhem/Cloak.png")
}

onready var search:Control = $Search

var search_contents := []

var items := []
var search_items := []
var search_bgs := []
var is_search := false

func _ready():
	for x in PlayerInfo.INV_WIDTH:
		var is_locked:bool = x >= PlayerInfo.get_inventory_columns()
		var ref_tile := lock if is_locked else tile
		for y in PlayerInfo.INV_HEIGHT:
			var xy:TextureRect = ref_tile.duplicate()
			if is_locked:
				xy.theme = tooltip_theme
				xy.hint_tooltip = "Locked"
			xy.rect_position = PlayerInfo.INV_OFFSET + PlayerInfo.INV_DELTA * Vector2(x, y)
			add_child(xy)
	for x in 4:
		for y in 3:
			var xy:TextureRect = tile.duplicate()
			xy.rect_position = PlayerInfo.SEARCH_OFFSET + PlayerInfo.INV_DELTA * Vector2(x, y)
			search_bgs.append(xy)
			add_child(xy)
	_draw_items()

func _draw_items():
	for i in PlayerInfo.inventory:
		var ii:InventoryItem = item.instance()
		ii.search_drag = is_search
		ii.parent_container = PlayerInfo.inventory
		ii.other_container = search_contents if is_search else []
		ii.rect_position = PlayerInfo.INV_OFFSET + PlayerInfo.INV_DELTA * i["position"]
		ii.connect("equip_position_changed", self, "_refresh_equip_positions")
		ii.connect("remove_item", self, "_item_moved")
		ii.set_item(i)
		items.append(ii)
		add_child(ii)
	if is_search:
		for i in search_contents:
			var ii:InventoryItem = item.instance()
			ii.is_search = true
			ii.search_drag = true
			ii.parent_container = search_contents
			ii.other_container = PlayerInfo.inventory
			ii.rect_position = PlayerInfo.SEARCH_OFFSET + PlayerInfo.INV_DELTA * i["position"]
			ii.connect("remove_item", self, "_item_moved")
			ii.set_item(i)
			search_items.append(ii)
			add_child(ii)
			
	var mayhem_pos := Vector2(0, 0)
	for idx in MAYHEMS.size():
		var mayhem_name:String = MAYHEMS[idx]
		if PlayerInfo.get_mayhem_level(mayhem_name) > 0:
			var ii:InventoryMayhem = mayhem.instance()
			ii.set_info(mayhem_name, idx + 1, mayhem_textures[mayhem_name])
			ii.rect_position = MAYHEM_OFFSET + PlayerInfo.INV_DELTA * mayhem_pos
			if mayhem_pos.x == 1:
				mayhem_pos = Vector2(0, mayhem_pos.y + 1)
			else:
				mayhem_pos.x += 1
			add_child(ii)

func refresh_items():
	search.visible = is_search
	for ii in search_bgs: ii.visible = is_search
	for ii in items: remove_child(ii)
	for ii in search_items: remove_child(ii)
	items = []
	search_items = []
	_draw_items()

func _item_moved():
	if is_search:
		get_tree().call_group("equip_monitor", "update_ammo")
		if !PlayerInfo.inventory.has(PlayerInfo.current_weapon) && PlayerInfo.current_weapon != PlayerInfo.UNARMED:
			PlayerInfo.current_weapon = PlayerInfo.UNARMED
			get_tree().call_group("equip_monitor", "update_weapon")
	refresh_items()

func _refresh_equip_positions():
	for i in items:
		i.set_equip_order()

func get_equipment(idx:int) -> Item:
	for i in items:
		if i.equip_order == idx: return i.info
	return null

func _on_CloseButton_pressed(): emit_signal("close_search")
