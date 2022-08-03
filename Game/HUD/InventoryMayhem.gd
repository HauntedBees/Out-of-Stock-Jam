class_name InventoryMayhem
extends Control

signal play_sound(sound)
onready var equip_label:Label = $EquipSlot
onready var item:TextureRect = $Item

var mayhem_name := ""
var equip_slot := 0
var texture:Texture
var hover := false

func set_info(name:String, slot:int, tex:Texture):
	mayhem_name = name
	equip_slot = slot
	texture = tex
func _ready():
	hint_tooltip = "%s (Level %s)" % [mayhem_name, PlayerInfo.get_mayhem_level(mayhem_name)]
	item.texture = texture
	equip_label.text = String(equip_slot)

func _on_mouse_entered(): hover = true
func _on_mouse_exited(): hover = false
func _input(event:InputEvent):
	if !hover: return
	var is_hitting_use:bool = (event.is_action("mayhem") && GASInput.is_action_just_pressed("mayhem")) || (event.is_action("use") && GASInput.is_action_just_pressed("use"))
	if !is_hitting_use: return
	if equip_slot <= 0:
		emit_signal("play_sound", "No")
		return
	var player = get_tree().get_nodes_in_group("player")[0]
	if player.active_mayhem > 0:
		emit_signal("play_sound", "No")
		return
	PlayerInfo.current_mayhem = mayhem_name
	get_tree().call_group("equip_monitor", "update_mayhem")
