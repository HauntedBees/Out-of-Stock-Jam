extends Control

onready var cutscene_text:RichTextLabel = $Textbox/CutsceneText

var cutscene_dialog:PoolStringArray = [
	"[color=#CCAAAA]Roboton[/color]: Well well well, if it isn't the late riser! You cryo-slept right through my little spectacle!",
	"[color=#CCAAAA]Roboton[/color]: I don't usually do encores, but you missed such an amazing performance!",
	"[color=#CCAAAA]Roboton[/color]: And since you're the only non-robot non-corpse left on this pesky colony, I believe I owe it to you!",
	"[color=#CCAAAA]Roboton[/color]: Prepare for the fight of a lifetime, my friend! You won't last long!"
]
var cutscene_idx := 0

func _ready(): cutscene_text.bbcode_text = cutscene_dialog[0]

func _is_action(event:InputEvent, action:String) -> bool:
	return event.is_action(action) && GASInput.is_action_just_pressed(action)

func _input(event:InputEvent):
	if !(_is_action(event, "action") || _is_action(event, "use")):
		return
	cutscene_idx += 1
	if cutscene_idx >= cutscene_dialog.size():
		PlayerInfo.current_map = "CommandCenter"
		SceneSwitcher.switch_scene("res://Maps/CommandCenter.tscn", false)
		return
	cutscene_text.bbcode_text = cutscene_dialog[cutscene_idx]
