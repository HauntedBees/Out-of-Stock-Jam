extends Control

signal closed()

onready var beep_ping:AudioStreamPlayer = $BeepSound
onready var no_ping:AudioStreamPlayer = $NoSound
onready var hover_ping:AudioStreamPlayer = $HoverSound

onready var shard_count:Label = $Shards/ShardAmount
onready var info_label:Label = $InfoLabel

onready var panel:TextureRect = $InfoPanel
onready var panel_image:TextureRect = $InfoPanel/MayhemImage
onready var panel_name:Label = $InfoPanel/MayhemLabel
onready var panel_text:Label = $InfoPanel/MayhemText
onready var panel_button:Button = $InfoPanel/HBoxContainer/BuyButton

var current_mayhem := ""
var current_mayhem_cost := 0

func _ready(): set_shards(false)
func set_shards(play_ping := true):
	if play_ping: beep_ping.play()
	shard_count.text = String(PlayerInfo.emerald_shards)

func _on_select_mayhem(name:String, image:Texture, text:String, cost:int):
	current_mayhem_cost = cost
	current_mayhem = name
	panel.visible = true
	panel_image.texture = image
	panel_name.text = name
	panel_text.text = text
	if cost == 0:
		panel_button.text = "Max Level Reached"
		panel_button.disabled = true
	else:
		panel_button.text = "Buy (%s Shards)" % cost
		panel_button.disabled = false

func _on_CancelButton_pressed(): panel.visible = false

func _on_BuyButton_pressed():
	if PlayerInfo.emerald_shards < current_mayhem_cost:
		no_ping.play()
		return
	beep_ping.play()
	PlayerInfo.emerald_shards -= current_mayhem_cost
	shard_count.text = String(PlayerInfo.emerald_shards)
	PlayerInfo.increase_mayhem_level(current_mayhem)
	if current_mayhem == "Vision":
		get_tree().call_group("player", "update_environment")
	panel.visible = false

func _on_CloseButton_pressed():
	beep_ping.play()
	emit_signal("closed")

func _on_WtfButton_pressed():
	beep_ping.play()
	$AcceptDialog.popup_centered()

func _on_button_mouse_entered(): hover_ping.play()
func _on_AcceptDialog_popup_hide(): beep_ping.play()
