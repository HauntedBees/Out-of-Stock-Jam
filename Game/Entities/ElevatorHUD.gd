class_name ElevatorHUD
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
var elevator_name:String

func display_hud(current_floor:String, current_story:int, elevator_type:String):
	elevator_name = "Elevator_%s" % elevator_type
	visible = true
	PlayerInfo.paused = true
	PlayerInfo.in_elevator = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	for b in buttons:
		b.visible = false
	match elevator_type:
		"REGULAR":
			if current_story == 0:
				broken_floor2.visible = current_floor != "Arboreals"
				broken_floor3.visible = current_floor != "Medical Bay"
				label.text = "The elevator is stuck on the first floor. You can climb down the shaft to reach the second floor, then you can find the service elevator to the first floor there."
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

func _on_GoBack_pressed():
	visible = false
	PlayerInfo.paused = false
	PlayerInfo.in_elevator = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_Arboreals_pressed(): _go_to_map("Arboreals")
func _on_MedBay_pressed(): _go_to_map("Medical Bay")

func _go_to_map(map:String):
	visible = false
	PlayerInfo.paused = false
	PlayerInfo.in_elevator = false
	PlayerInfo.current_map = map
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "Map", "save_to_dictionary")
	SceneSwitcher.switch_scene("res://Maps/%s.tscn" % map, false)
	SceneSwitcher.memory = {
		"source": "MAP",
		"destination": elevator_name
	}
