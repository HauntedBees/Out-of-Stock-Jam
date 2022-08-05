extends Control

onready var cutscene_text:RichTextLabel = $Textbox/CutsceneText
onready var lose:Control = $LoseRect
onready var tween:Tween = $Tween

var bad_cutscene_dialog:PoolStringArray = [
	"[color=#CCAAAA]Roboton[/color]: You... who do you think you are!?",
	"[color=#CCAAAA]Roboton[/color]: You're smiling... you think you've won?",
	"[color=#CCAAAA]Roboton[/color]: Do [color=#FF00FF]you[/color] have a way off this scrap heap? No? No giant robot? No spaceship? Well I do!",
	"[color=#CCAAAA]Roboton[/color]: You may have won the battle but I'll win the war! SELF DESTRUCT SEQUENCE ACTIVATE!",
	"[color=#CCAAAA]Roboton[/color]: Ta-ta for now! And forever! HA HA HA HA HAHAHAA!"
]
var good_cutscene_dialog:PoolStringArray = [
]
var cutscene_idx := 0
var cutscene_dialog:PoolStringArray = bad_cutscene_dialog if PlayerInfo.mayhem_rubies < 4 else good_cutscene_dialog
var ready_to_title := false

func _ready(): cutscene_text.bbcode_text = cutscene_dialog[0]

func _is_action(event:InputEvent, action:String) -> bool:
	return event.is_action(action) && GASInput.is_action_just_pressed(action)

func _input(event:InputEvent):
	if !(_is_action(event, "action") || _is_action(event, "use")):
		return
	cutscene_idx += 1
	if cutscene_idx >= cutscene_dialog.size():
		if ready_to_title:
			SceneSwitcher.switch_scene("res://TitleScreen.tscn", false)
		if PlayerInfo.mayhem_rubies >= 4:
			pass # GOOD END
		else:
			tween.interpolate_property(lose, "modulate:a", 0.0, 1.0, 2.0)
			tween.start()
			ready_to_title = true
		return
	cutscene_text.bbcode_text = cutscene_dialog[cutscene_idx]
