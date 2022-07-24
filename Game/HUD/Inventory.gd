extends Control

onready var item:PackedScene = preload("res://HUD/InventoryItem.tscn")
onready var tile:TextureRect = $TileRect
onready var lock:TextureRect = $LockedRect

const OFFSET := Vector2(16, 64)
const WIDTH := 12
const HEIGHT := 3
const DELTA := 96

func _ready():
	var available_rows = PlayerInfo.inventory_rows
	for x in WIDTH:
		var ref_tile := tile if x < available_rows else lock
		for y in HEIGHT:
			var xy:TextureRect = ref_tile.duplicate()
			xy.rect_position = OFFSET + DELTA * Vector2(x, y)
			add_child(xy)
	for i in PlayerInfo.inventory:
		var ii:InventoryItem = item.instance()
		ii.rect_position = OFFSET + DELTA * i["position"]
		ii.set_item(i)
		add_child(ii)
