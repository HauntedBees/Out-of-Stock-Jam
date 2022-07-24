extends Control

onready var item:PackedScene = preload("res://HUD/InventoryItem.tscn")
onready var tile:TextureRect = $TileRect
onready var lock:TextureRect = $LockedRect

var items := []

func _ready():
	var available_rows = PlayerInfo.inventory_rows
	for x in PlayerInfo.INV_WIDTH:
		var ref_tile := tile if x < available_rows else lock
		for y in PlayerInfo.INV_HEIGHT:
			var xy:TextureRect = ref_tile.duplicate()
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
