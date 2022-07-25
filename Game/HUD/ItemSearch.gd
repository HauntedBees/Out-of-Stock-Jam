extends Control

signal close_search()

onready var item:PackedScene = preload("res://HUD/InventoryItem.tscn")
onready var tile:TextureRect = $TileRect

var container_contents := []
var items := []

func _ready():
	for x in 4:
		for y in 3:
			var xy:TextureRect = tile.duplicate()
			xy.rect_position = PlayerInfo.SEARCH_OFFSET + PlayerInfo.INV_DELTA * Vector2(x, y)
			add_child(xy)

func _draw_items():
	for i in container_contents:
		var ii:InventoryItem = item.instance()
		ii.is_search = true
		ii.search_drag = true
		ii.parent_container = container_contents
		ii.rect_position = PlayerInfo.SEARCH_OFFSET + PlayerInfo.INV_DELTA * i["position"]
		ii.connect("equip_position_changed", self, "_refresh_equip_positions")
		ii.connect("remove_item", self, "_remove_item", [i])
		ii.set_item(i)
		items.append(ii)
		add_child(ii)

func _remove_item(i:Item):
	container_contents.erase(i)
	refresh_items()

func refresh_items():
	for ii in items: remove_child(ii)
	items = []
	_draw_items()

func set_contents(container:Interactable):
	container_contents = container.contents
	refresh_items()

func _on_CloseButton_pressed(): emit_signal("close_search")
