class_name InventoryMayhem
extends Control

onready var equip_label:Label = $EquipSlot
onready var item:TextureRect = $Item

var mayhem_name := ""
var equip_slot := 0
var texture:Texture

func set_info(name:String, slot:int, tex:Texture):
	mayhem_name = name
	equip_slot = slot
	texture = tex
func _ready():
	hint_tooltip = "%s (Level %s)" % [mayhem_name, PlayerInfo.get_mayhem_level(mayhem_name)]
	item.texture = texture
	equip_label.text = String(equip_slot)
