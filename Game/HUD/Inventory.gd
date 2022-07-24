extends Control

onready var tooltip_theme:Theme = preload("res://HUD/Tooltip.tres")
onready var item:PackedScene = preload("res://HUD/InventoryItem.tscn")
onready var tile:TextureRect = $TileRect
onready var lock:TextureRect = $LockedRect

var items := []

func _ready():
	for x in PlayerInfo.INV_WIDTH:
		var is_locked:bool = x >= PlayerInfo.inventory_columns
		var ref_tile := lock if is_locked else tile
		for y in PlayerInfo.INV_HEIGHT:
			var xy:TextureRect = ref_tile.duplicate()
			if is_locked:
				xy.theme = tooltip_theme
				xy.hint_tooltip = "Locked"
			xy.rect_position = PlayerInfo.INV_OFFSET + PlayerInfo.INV_DELTA * Vector2(x, y)
			add_child(xy)
	_draw_items()

func _draw_items():
	for i in PlayerInfo.inventory:
		var ii:InventoryItem = item.instance()
		ii.rect_position = PlayerInfo.INV_OFFSET + PlayerInfo.INV_DELTA * i["position"]
		ii.connect("equip_position_changed", self, "_refresh_equip_positions")
		ii.connect("remove_item", self, "_remove_item", [i])
		ii.set_item(i)
		items.append(ii)
		add_child(ii)

func _remove_item(i:Item):
	PlayerInfo.inventory.erase(i)
	refresh_items()

func refresh_items():
	for ii in items: remove_child(ii)
	items = []
	_draw_items()

func _refresh_equip_positions():
	for i in items:
		i.set_equip_order()

func get_equipment(idx:int) -> Item:
	for i in items:
		if i.equip_order == idx: return i.info
	return null
