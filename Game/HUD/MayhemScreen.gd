extends Control

onready var shard_count:Label = $Shards/ShardAmount
onready var info_label:Label = $InfoLabel

onready var panel:TextureRect = $InfoPanel
onready var panel_image:TextureRect = $InfoPanel/MayhemImage
onready var panel_name:Label = $InfoPanel/MayhemLabel
onready var panel_text:Label = $InfoPanel/MayhemText
onready var panel_button:Button = $InfoPanel/HBoxContainer/BuyButton

var current_mayhem := ""
var current_mayhem_cost := 0

func _ready(): shard_count.text = String(PlayerInfo.emerald_shards)

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
		# TODO: play a no no sound
		return
	PlayerInfo.emerald_shards -= current_mayhem_cost
	shard_count.text = String(PlayerInfo.emerald_shards)
	PlayerInfo.increase_mayhem_level(current_mayhem)
	# TODO: play an AW YEAH noise
	panel.visible = false
