extends Control

onready var label:Label = $Box/VBoxContainer/Label
onready var broken_floor2:Button = $Box/VBoxContainer/GoFloor2_Climb
onready var broken_floor3:Button = $Box/VBoxContainer/GoFloor3_Climb
onready var shaft_floor1:Button = $Box/VBoxContainer/GoFloor1_Shaft
onready var shaft_floor2:Button = $Box/VBoxContainer/GoFloor2_Shaft
onready var regular_floor1:Button = $Box/VBoxContainer/GoFloor1_Normal
onready var regular_floor2:Button = $Box/VBoxContainer/GoFloor2_Normal
onready var regular_floor3:Button = $Box/VBoxContainer/GoFloor3_Normal
onready var regular_floor4:Button = $Box/VBoxContainer/GoFloor4_Normal
onready var special_floor5:Button = $Box/VBoxContainer/GoFloor5_Normal
onready var buttons := [
	broken_floor2, broken_floor3, 
	shaft_floor1, shaft_floor2, 
	regular_floor1, regular_floor2, regular_floor3, regular_floor4, 
	special_floor5
]

func display_hud(current_floor:String, current_story:int, elevator_type:String):
	visible = true
	PlayerInfo.paused = true
	PlayerInfo.in_elevator = true
	for b in buttons:
		b.visible = false
	match elevator_type:
		"REGULAR":
			if current_story == 0:
				broken_floor2.visible = current_floor != "Arboreals"
				broken_floor3.visible = current_floor != "Medical Bay"
			else:
				regular_floor1.visible = current_floor != "Engineering"
				regular_floor2.visible = current_floor != "Arboreals"
				regular_floor3.visible = current_floor != "Medical Bay"
				regular_floor4.visible = current_floor != "Crew Quarters"
		"SERVICE":
			shaft_floor1.visible = current_floor != "Engineering"
			shaft_floor2.visible = current_floor != "Arboreals"
		"EXECUTIVE":
			regular_floor4.visible = current_floor != "Crew Quarters"
			special_floor5.visible = current_floor != "Command Center"
